module.exports =
  serve:
    options:
      compress: false,
      # yuicompress: true,
      # optimization: 2
    files:
      ".tmp/styles/wc-kube.css": "src/less/kube.less"
