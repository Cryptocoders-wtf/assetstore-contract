import { readdirSync, readFileSync } from "fs";
import { XMLParser } from "fast-xml-parser";

const options = {
  ignoreAttributes: false,
  format: true,
};

const parser = new XMLParser(options);

const path = '../material/src/alert';
const files = readdirSync(path);
console.log(files);
files.map((file) => {
  const path2 = `${path}/${file}/materialicons`;
  let files2 = readdirSync(path2);
  files2 = files2.sort((f0, f1) => {
    return parseInt(f0) > parseInt(f1) ? -1 : 1 ;
  });
  let xml = readFileSync(`${path2}/${files2[0]}`, 'utf8');
  const obj = parser.parse(xml);
  const paths = obj.svg.path;
  console.log("***", file, paths);
  /*
  paths.map((path2:any) => {
    console.log(path2);
  });
  */
});
