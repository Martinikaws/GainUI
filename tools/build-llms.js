// Writes llms.txt, llms-full.txt and md/<page>.md from the pages in index.html,
// so AI tools (and the mcpdoc MCP server) read the same docs people do.
// Run after changing the docs:  node tools/build-llms.js
const fs = require("fs");
const path = require("path");

const root = path.join(__dirname, "..");
const html = fs.readFileSync(path.join(root, "index.html"), "utf8");
const start = html.indexOf("<script>") + "<script>".length;
const end = html.indexOf("// Routing & rendering");
if (start < 8 || end < 0) throw new Error("index.html: couldn't find the page code");

// Everything above "Routing & rendering" is plain data and string building.
const docs = new Function(html.slice(start, end) + "\nreturn {PAGES, pageMarkdown, llmsTxtFull, llmsFull, mdName};")();

const mdDir = path.join(root, "md");
fs.rmSync(mdDir, {recursive: true, force: true});
fs.mkdirSync(mdDir);
for (const p of docs.PAGES) fs.writeFileSync(path.join(mdDir, docs.mdName(p.id)), docs.pageMarkdown(p));
fs.writeFileSync(path.join(root, "llms.txt"), docs.llmsTxtFull());
fs.writeFileSync(path.join(root, "llms-full.txt"), docs.llmsFull());
console.log(`llms.txt, llms-full.txt and ${docs.PAGES.length} pages in md/`);
