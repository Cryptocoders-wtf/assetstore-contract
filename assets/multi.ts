import { loadAssets } from "./createAsset";

const misc = {
  group: "Misc.",
  category: "Standard",
  width: 24, height: 24,
  assets:[{
    name: "Done",
    parts: [{
      color: "",
      body: "M2 2h15v15h-15z",
    },{
      color: "yellow",
      body: "M5 5h15v15h-15z",
    },{
      color: "blue",
      body: "M7 7h15v15h-15z",
    },{
      color: "#ff000080",
      body: "M9 9h15v15h-15z",
    }]
  }]
};

export const multiAssets = loadAssets(misc);
