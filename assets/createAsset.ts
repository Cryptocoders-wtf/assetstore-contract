const assetBase:any = {
  width: 24, height: 24,
  minter: ""
};

const regex = /[+-\d\.]+/g;
const encoder = new TextEncoder();

const convert:any = (body:string, width:number) => {
  let ret:string = body.replace(regex, (str:string) => {
    return String(Math.round(parseFloat(str) * 1000 / width));
  });
  return encoder.encode(ret);
};

export const createAsset = (_asset:any, group:string, category:string) => {
  let asset = Object.assign({}, assetBase);
  asset.group = group;
  asset.category = category;
  asset.name = _asset.name;
  const width = _asset.width || 24;
  asset.width = 1000;
  asset.height = 1000;
  if (_asset.parts) {
    asset.parts = _asset.parts.map((part:any) => {
      part.mask = convert(part.mask || "");
      part.color = part.color || "";
      part.body = convert(part.body);
      return part;
    });
  } else {
    asset.parts = [{
      mask: convert(""), color: "",
      body: convert(_asset.body)
    }];
  }
  return asset;  
}