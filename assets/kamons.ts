import { loadAssets } from "../utils/createAsset";
import { assets } from "./kamon_assets";

// http://hakko-daiodo.com/main-0
const misc = {
  group: "Hakko Daiodo (CC-BY-SA)",
  category: "Kamon",
  assets
};

export const kamonAssets = loadAssets(misc);
