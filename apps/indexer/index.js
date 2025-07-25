import yaml from "js-yaml";
import fs from "fs";
import path from "path";
import { fileURLToPath, pathToFileURL } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Step 1: Read and parse original YAML
const originalYamlPath = path.resolve(__dirname, "./rindexer.yaml");
const yamlContent = fs.readFileSync(originalYamlPath, "utf8");
const parsed = yaml.load(yamlContent);

// Step 2: Use import.meta.resolve to find the ABI JSON path
const resolvedAbiUrl = import.meta.resolve("@planet/abi/NFTMarketplace.json");
const resolvedAbiPath = path
  .relative(path.dirname(originalYamlPath), fileURLToPath(resolvedAbiUrl))
  .replace(".json", "");

// Step 3: Patch the YAML
for (const contract of parsed.contracts ?? []) {
  if (contract.name === "NFTMarketplace") {
    contract.abi = resolvedAbiPath;
  }
}

// Step 4: Write back
fs.writeFileSync(originalYamlPath, yaml.dump(parsed), {
  encoding: "utf-8",
});

console.log(`✅ rindexer.yaml updated`);
