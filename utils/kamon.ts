import { readdirSync, readFileSync, writeFileSync, existsSync } from "fs";
import { XMLParser } from "fast-xml-parser";

const options = {
  ignoreAttributes: false,
  format: true,
};

const parser = new XMLParser(options);

const root = './svgs/kamons';
const categories = readdirSync(root);
//console.log(categories);
categories.map(category => {
  if (category == '.DS_Store') {
    return;
  }
  let files = readdirSync(`${root}/${category}`);
  //console.log(category, files.length);
  if (category == 'ikari') {
    let files = readdirSync(`${root}/${category}`);
    //console.log(files);
    const items = files.filter((file, index) => {
      return index < 100;
    })
    .filter((file, index) =>{ return (index>=0 && index<=999) && file != '.DS_Store'; })
    .map((file, index) => {
      let xml = readFileSync(`${root}/${category}/${file}`, 'utf8');
      //console.log(xml);
      const obj = parser.parse(xml);
      const svg = obj.svg;
      const width = parseInt(svg['@_width']);
      const height = parseInt(svg['@_height']);
      if (svg.path && (!svg.rect || !Array.isArray(svg.rect)) && !svg.g && !svg.polygon && !svg.circle) {
        const paths = Array.isArray(svg.path) ? svg.path : [svg.path];
        const bodies = paths.filter((path:any) => {
          return !path['@_fill'] && path['@_style'] != "fill:none";
        }).map((path:any) => {
          return path['@_d'];
        });
        const item = { name:file.replace(/\.svg/, "").replace(/_/g, " "), width, height, bodies };
        return item;
      } else {
        console.error(file, svg);
        process.exit(0);
      }
    });
    console.log(`export const assets = ${JSON.stringify(items)} ;`);
  }
});
  /*
  mkdir(`./svgs/materials/${category}`, { recursive:false }, (err)=>{
    console.error(err);
  });
  */
 /*
  const path = `../material/src/${category}`;
  const files = readdirSync(path);
  files.map((file) => {
    const path2 = `${path}/${file}/materialicons`;
    if (existsSync(path2)) {
      let files2 = readdirSync(path2);
      files2 = files2.sort((f0, f1) => {
        return parseInt(f0) > parseInt(f1) ? -1 : 1 ;
      });
      let xml = readFileSync(`${path2}/${files2[0]}`, 'utf8');
      writeFileSync(`./svgs/materials/${category}/${file}.svg`, xml, 'utf8');
    }
    const obj = parser.parse(xml);
    const svg = obj.svg;
    const width = parseInt(svg['@_width']);
    const height = parseInt(svg['@_height']);
    if (svg.path) {
      const paths = svg.path;
      console.log("***", file, width, height, "***", paths);
    } else if (svg.g) {
      const g = svg.g;
      console.log("***", file, width, height, "***", g);
    } else {
      console.error("error", file);
    }
    */
    /*
    paths.map((path2:any) => {
      console.log(path2);
    });
  });
})
    */

