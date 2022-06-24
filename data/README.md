# Asset format

## Asset

- name:
  - name: Asset name
  - type: string
- minterName:
  - name: Your minter name
  - type: string
- category:
  - name: Category name
  - type: string
- group:
  - name: Group Name
  - type: string
- width;
  - name: Asset width
  - type: number
- height:
  - name: Asset height
  - type: number
- parts:
  - name: Parts data(SVG data)
  - type: Parts Array

# Parts
- body
  - name: SVG body.
  - description: The value of d in path
  - type: string
- mask
  - name: SVG color. 
  - description: Allow color name(blue), HEX(#4169E1), RGB or RGBA (rgba(0,0,0,0) )
  - type: string
- color
  - name: SVG mask
  - type: string


# Example
```
{
  name: "Home",
  minterName: "nounsfes",
  category: "UI Action",
  group: "Material Icons (Apache 2.0)",
  width: 24,
  height: 24,
  parts:[{
      body: "M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z",
      mask: "",
      color: "#4169E1"
  }]
}
```