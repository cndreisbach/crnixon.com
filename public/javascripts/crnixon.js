$.script.ready('prettify', function () {
  $.domReady(function () {
    $("pre > code[class]").parents("pre").
      addClass("prettyprint").
      each(function (el) {
        var $el = $(el);
        var lang = $el.children().first().attr('class');
        $el.addClass('lang-' + lang);
      });
    if ($(".prettyprint").length) {
      prettyPrint();
    }
  });
});
