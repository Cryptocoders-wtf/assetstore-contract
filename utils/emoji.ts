import { readdirSync, readFileSync, writeFileSync, existsSync } from "fs";
import { XMLParser } from "fast-xml-parser";

const options = {
  ignoreAttributes: false,
  format: true,
};

const parser = new XMLParser(options);
const regex = /fill:(#[0-9a-fA-F]+)/;
const regexErr = /e-[1-9]/;
const root = './svgs/emoji';
const categories = readdirSync(root);
//console.log(categories);
categories.map(category => {
  if (category == '.DS_Store') {
    return;
  }
  let files = readdirSync(`${root}/${category}`);
  //console.log(category, files.length);
  if (category == 'flags') {
    let files = readdirSync(`${root}/${category}`);
    //console.log(files);
    const items = files.filter((file, index) => {
      return index < 100;
    })
    .filter((file, index) =>{ return (index>=0 && index<60) && file != '.DS_Store'; })
    .map((file, index) => {
      let xml = readFileSync(`${root}/${category}/${file}`, 'utf8');
      //console.log(xml);
      const obj = parser.parse(xml);
      const svg = obj.svg;
      const width = parseInt(svg['@_width']) || 72;
      const height = parseInt(svg['@_height']) || 72;
      if (svg.path && (!svg.rect || !Array.isArray(svg.rect)) && !svg.g && !svg.polygon && !svg.circle) {
        const paths = Array.isArray(svg.path) ? svg.path : [svg.path];
        const parts = paths.filter((path:any) => {
          return true; // !path['@_fill'] && path['@_style'] != "fill:none";
        }).map((path:any) => {
          if (regexErr.test(path['@_d']) || path['@_transform']) {
            console.error(file, path['@_d']);
            process.exit(0);
          }
          if (path['@_fill']) {
            return { body:path['@_d'], color: path['@_fill'] };
          } else if (path['@_style']) {
            const result = regex.exec(path['@_style']);
            //console.log(result);
            if (result) {
              return { body:path['@_d'], color: result[1] };
            }
          }
          return { body:path['@_d'] };
        });
        const item = { name:file.replace(/\.svg/, "").replace(/_/g, " "), width, height, parts };
        return item;
      } else {
        console.error(file, svg);
        process.exit(0);
      }
    });
    console.log(`export const assets = ${JSON.stringify(items)} ;`);
  }
});