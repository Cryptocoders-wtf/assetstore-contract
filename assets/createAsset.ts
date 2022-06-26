const assetBase:any = {
  width: 24, height: 24,
  minter: ""
};

const regexNum = /[+-\d\.]+/;
const regexNumG = /[+-\d\.]+/g;
const regexDivG = /[,\s]+/g;
const encoder = new TextEncoder();

const compressPath = (body:string, width:number) => {
  let ret = body.replace(regexNumG, (str:string)=>{
    return ` ${Math.round(parseFloat(str) * 1000 / width)} `;
  });
  const items = ret.split(regexDivG);

  const numArray:Array<number> = items.map((item:string) => {
    if (regexNum.test(item)) {
      return parseFloat(item) + 256 + 1024;
    } else {
      return item.charCodeAt(0);
    }
  });

  const bytes = new Uint8Array(numArray.length * 2);
  numArray.map((value, index) => {
    bytes[index * 2] = value % 0x100; // little-endian
    bytes[index * 2 + 1] = value / 0x100; 
  });

  return bytes;
} 

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
      part.mask = compressPath(part.mask || "", width);
      part.color = part.color || "";
      part.body = compressPath(part.body, width);
      return part;
    });
  } else {
    asset.parts = [{
      mask: compressPath("", width), color: "",
      body: compressPath(_asset.body, width)
    }];
  }
  return asset;  
}