const assetBase:any = {
    width: 24, height: 24,
    group: "Material Icons (Apache 2.0)",
    minter: "",
    parts:[{
        mask: "", color: ""
    }]
  };
  
  export const createAsset = (_asset:any, category:string) => {
    let asset = Object.assign({}, assetBase);
    asset.category = category;
    asset.name = _asset.name;
    if (_asset.width) {
      asset.width = _asset.width;
      asset.height = _asset.height;
    }
    asset.parts[0].body = _asset.body;
    return asset;  
  }