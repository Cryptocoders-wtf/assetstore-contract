const assetBase:any = {
  width: 24, height: 24,
  minter: ""
};

const regex = /[+-\d\.]+/g

export const createAsset = (_asset:any, group:string, category:string) => {
  let asset = Object.assign({}, assetBase);
  asset.group = group;
  asset.category = category;
  asset.name = _asset.name;
  if (_asset.width) {
    asset.width = _asset.width;
    asset.height = _asset.height;
  }
  if (_asset.parts) {
    asset.parts = _asset.parts;
  } else {
    asset.parts = [{
      mask: "", color: "",
      body: _asset.body.replace(regex, (str:string)=>{
        return parseFloat(str)
      })
    }];
  }
  return asset;  
}