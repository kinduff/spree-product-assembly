#= require ./translations

Spree.routes.available_admin_product_parts = (productSlug) ->
  Spree.pathFor("admin/products/" + productSlug + "/parts/available")

showErrorMessages = (xhr) ->
  response = JSON.parse(xhr.responseText)
  show_flash("error", response)

searchForParts = ->
  productSlug = $("#product_parts").data("product-slug")
  searchUrl = Spree.routes.available_admin_product_parts(productSlug)

  $.ajax
   data:
     q: $("#searchtext").val()
   dataType: 'html'
   success: (request) ->
     $("#search_hits").html(request)
     $("#search_hits").show()
     $('select.select2').select2()
   type: 'POST'
   url: searchUrl

$(document).on 'keypress', "#searchtext", (e) ->
  if (e.which && e.which == 13) || (e.keyCode && e.keyCode == 13)
    searchForParts()
    false
  else
    true

$(document).on 'click', "#search_parts_button", (e) ->
  e.preventDefault()
  searchForParts()

makePostRequest = (link, post_params = {}) ->
  spinner = $("img.spinner", link.parent())
  spinner.show()

  request = $.ajax
    type: "POST"
    url: link.attr("href")
    data: post_params
    dateType: "script"
  request.fail showErrorMessages
  request.always -> spinner.hide()

  false

$(document).on "click", "#search_hits a.add_product_part_link", (event) ->
  event.preventDefault()

  part = {}
  link = $(this)
  row = $("#" + link.data("target"))
  loadingIndicator = $("img.spinner", link.parent())
  quantityField = $('input:last', row)

  part.count = quantityField.val()

  if row.hasClass("with-variants")
    selectedVariantOption = $('select.part_selector option:selected', row)
    part.part_id = selectedVariantOption.val()

    if selectedVariantOption.text() == Spree.translations.user_selectable
      part.variant_selection_deferred = "t"
      part.part_id = link.data("master-variant-id")

  else
    part.part_id = $('input[name="part[id]"]', row).val()

  part.assembly_id = $('[name="part[assembly_id]"]', row).val()

  makePostRequest(link, {assemblies_part: part})

$(document).on "click", "#product_parts a.set_count_admin_product_part_link", ->
  params = { count: $("input", $(this).parent().parent()).val() }
  makePostRequest($(this), params)

$(document).on "click", "#product_parts a.remove_admin_product_part_link", ->
  console.log('baby')
  makePostRequest($(this))
