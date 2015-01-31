module.exports =
  serve:
    options:
      compress: false,
      # yuicompress: true,
      # optimization: 2
    files:
      ".tmp/styles/wc-robe.css": "src/less/wcrobe.less"
  dist:
    options:
      compress: false,
      # yuicompress: true,
      # optimization: 2
    files:
      "./dist/styles/wcrobe.css": "src/less/wcrobe.less"
