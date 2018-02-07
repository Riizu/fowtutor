$(document).ready(function(){
    $(".deck-adjust-button").click(function(){
        card_name = $(this).parents('tr').data("name")
        card_name_sanitized = card_name.replace(/\s+/g, '-').replace(/,/g, '').replace(/'/g, '').toLowerCase();
        num_cards = $(this).parents('tr').find("#num-cards").val()
        deck = $(this).text().toLowerCase() + "-deck"
        console.log(card_name + "|" + num_cards + "|" + deck)

        deck_div = $("#" + deck)
        deck_div.find("#" + card_name_sanitized).remove()

        if (parseInt(num_cards) > 0) {
            deck_div.append("<div id=" + card_name_sanitized + ">" + num_cards + "x " + card_name + "</div>")
        }
    });
});