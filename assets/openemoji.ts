import { createAsset } from "./createAsset";

const emojis = [{
  name: "Done",
  parts: [{
    mask: "", color: "red",
    body: "M9 16.2L4.8 12l-1.4 1.4L9 19 21 7l-1.4-1.4L9 16.2z"
  }]
}];

export const enojiAssets = emojis.map(asset => {
  return createAsset(asset, "Open Emojis", "Extra");
});