const assetBase:any = {
  width: 24, height: 24,
  minter: ""
};

const regexNum = /[+-]?[\d\.]+/;
const regexNumG = /[+-]?[\d\.]+/g;
const regexDivG = /[,\s]+/g;
const encoder = new TextEncoder();

const compressPath = (body:string, width:number) => {
  const ret = body.replace(regexNumG, (str:string)=>{
    return ` ${Math.round(parseFloat(str) * 1024 / width)} `;
  });
  const items = ret.split(regexDivG);

  const numArray:Array<number> = items.reduce((prev:Array<number>, item:string) => {
    if (regexNum.test(item)) {
      prev.push(parseFloat(item) + 256 + 1024);
    } else {
      let i;
      for (i = 0; i < item.length; i++) {
        prev.push(item.charCodeAt(i));
      }
    }
    return prev;
  }, []);

  // Middle-endien compression
  const bytes = new Uint8Array((numArray.length * 3 + 1) / 2);
  numArray.map((value, index) => {
    const offset = index / 2 * 3;
    if (index % 2 == 0) {
      bytes[offset] = value % 0x100; // low 8 bits in the first byte
      bytes[offset + 1] = (value / 0x100) & 0x0f; // hight 4 bits in the low 4 bits of middle byte 
    } else {
      bytes[offset + 2] = value % 0x100; // low 8 bits in the third byte
      bytes[offset + 1] |= (value / 0x100) * 0x10; // high 4 bits in the high 4 bits of middle byte
    }
  });

  return bytes;
} 

export const createAsset = (_asset:any, group:string, category:string) => {
  const asset = Object.assign({}, assetBase);
  asset.group = group;
  asset.category = category;
  asset.name = _asset.name;
  const width = _asset.width || 24;
  asset.width = 1024;
  asset.height = 1024;
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
