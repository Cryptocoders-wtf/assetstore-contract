import { createAsset } from "./createAsset";

const misc = [{
  name: "Done",
  parts: [{
    mask: "", color: "yellow",
    body: "M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z",
  },{
    mask: "", color: "blue",
    body: "M9 16.2L4.8 12l-1.4 1.4L9 19 21 7l-1.4-1.4L9 16.2z"
  }]
}];

export const multiAssets = misc.map(asset => {
  return createAsset(asset, "Misc.", "Standard");
});