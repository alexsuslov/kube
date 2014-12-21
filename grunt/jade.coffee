module.exports =
  serve:
    options:
      pretty: true
    files:[
      expand: true
      cwd: "src/jade/"
      src: "*.jade"
      dest: "app/"
      ext: ".html"
    ,
      expand: true
      cwd: "src/jade/component"
      src: "*.jade"
      dest: "app/component"
      ext: ".html"
    ]

