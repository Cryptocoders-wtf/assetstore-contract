import { actions, social } from "../assets/materials";
import { createAsset } from "../assets/createAsset";

actions.map((action) => {
  const from = action.body.length;
  const asset = createAsset(action, "12", "12")
  const to = asset.parts[0].body.length;
  console.log(`from: ${from} to: ${to}`);
});
social.map((action) => {
  const from = action.body.length;
  const asset = createAsset(action, "12", "12")
  const to = asset.parts[0].body.length;
  console.log(`from: ${from} to: ${to}`);
});
