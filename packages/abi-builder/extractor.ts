import fs from "fs/promises";
import path from "path";
import { fileURLToPath } from "url";
import { contractsToExtract } from "./config.ts";

console.log("🔍 ABI extraction starting...");

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const contractsOutPath = path.join(__dirname, "../../apps/contract/out");
const abiOutPath = path.join(__dirname, "../abi");

async function ensureDir(dir: string) {
  try {
    await fs.mkdir(dir, { recursive: true });
  } catch (e) {
    console.error(`Failed to create directory ${dir}:`, e);
    process.exit(1);
  }
}

async function extractAbis() {
  try {
    // Ensure output folder exists
    await ensureDir(abiOutPath);

    const contractFolders = await fs.readdir(contractsOutPath, {
      withFileTypes: true,
    });
    if (contractFolders.length === 0) {
      console.warn(`⚠️ No contract folders found in ${contractsOutPath}`);
      return;
    }

    let exportedCount = 0;

    for (const folder of contractFolders) {
      if (!folder.isDirectory()) continue;

      const fullPath = path.join(contractsOutPath, folder.name);
      const files = await fs.readdir(fullPath);

      for (const file of files) {
        if (
          !file.endsWith(".json") ||
          !contractsToExtract.includes(file.split(".")[0])
        )
          continue;

        const filePath = path.join(fullPath, file);
        const contentRaw = await fs.readFile(filePath, "utf8");
        const content = JSON.parse(contentRaw);

        if (!content.abi) continue;

        const abiFileName = file.replace(".json", "") + ".json";
        const abiFilePath = path.join(abiOutPath, abiFileName);

        await fs.writeFile(abiFilePath, JSON.stringify(content.abi, null, 2));
        console.log(`✅ Exported ABI for ${abiFileName}`);
        exportedCount++;
      }
    }

    if (exportedCount === 0) {
      console.warn("⚠️ No ABIs found to export.");
    } else {
      console.log(`🎉 Finished exporting ${exportedCount} ABIs.`);
    }
    console.log(`⚙️  Find the config in package/abi-builder/config.ts`);
  } catch (err) {
    console.error("❌ Error extracting ABIs:", err);
    process.exit(1);
  }
}

extractAbis();
