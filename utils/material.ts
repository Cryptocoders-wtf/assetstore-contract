import { readdirSync, readFileSync } from "fs";

const regex = /d="/
const path = '../material/src/alert';
const files = readdirSync(path);
files.map((file) => {
  const path2 = `${path}/${file}/materialicons`;
  let files2 = readdirSync(path2);
  files2 = files2.sort((f0, f1) => {
    return parseInt(f0) > parseInt(f1) ? -1 : 1 ;
  });
  let xml = readFileSync(`${path2}/${files2[0]}`, 'utf8');
  xml = xml.substring(xml.search(regex) + 2);
  console.log(file, xml);
});
