import {
  closeSync, constants, existsSync, fstatSync, lstatSync, openSync,
  readSync, realpathSync, statSync
} from "node:fs";
import path from "node:path";

// An architecture map should stay small enough to fit in a model's context.
const MAX_DOCUMENT_BYTES = 1024 * 1024;

export function directoryPath(root: string): string {
  let resolved: string;
  try {
    resolved = realpathSync(root);
  } catch {
    throw new Error(`Project directory does not exist or cannot be accessed: ${root}`);
  }
  if (!statSync(resolved).isDirectory()) {
    throw new Error(`Project root must be a directory: ${root}`);
  }
  return resolved;
}

function readDocument(candidate: string): string | null {
  let info;
  try {
    info = lstatSync(candidate);
  } catch (error) {
    if ((error as NodeJS.ErrnoException).code === "ENOENT") return null;
    throw error;
  }
  if (!info.isFile()) {
    throw new Error(`ONBOARDING.md must be a regular file, not a symlink or directory: ${candidate}`);
  }

  // Do not follow a symlink swapped in after lstat, or block on a named pipe.
  const descriptor = openSync(candidate, constants.O_RDONLY | (constants.O_NOFOLLOW ?? 0) | (constants.O_NONBLOCK ?? 0));
  try {
    const opened = fstatSync(descriptor);
    if (!opened.isFile()) throw new Error(`ONBOARDING.md must be a regular file: ${candidate}`);
    if (opened.size > MAX_DOCUMENT_BYTES) throw new Error(`ONBOARDING.md exceeds the 1 MiB limit: ${candidate}`);

    // Bound the read itself as well, in case the file grows after the size check.
    const buffer = Buffer.alloc(MAX_DOCUMENT_BYTES + 1);
    let bytes = 0;
    while (bytes < buffer.length) {
      const count = readSync(descriptor, buffer, bytes, buffer.length - bytes, null);
      if (count === 0) break;
      bytes += count;
    }
    if (bytes > MAX_DOCUMENT_BYTES) throw new Error(`ONBOARDING.md exceeds the 1 MiB limit: ${candidate}`);
    return buffer.toString("utf8", 0, bytes);
  } finally {
    closeSync(descriptor);
  }
}

export function findOnboarding(startDir: string): { path: string; content: string } | null {
  let dir = directoryPath(startDir);
  for (;;) {
    const candidate = path.join(dir, "ONBOARDING.md");
    const content = readDocument(candidate);
    if (content !== null) return { path: candidate, content };
    // .git may be a directory (checkout) or a file (worktree/submodule).
    if (existsSync(path.join(dir, ".git"))) return null;
    const parent = path.dirname(dir);
    if (parent === dir) return null;
    dir = parent;
  }
}
