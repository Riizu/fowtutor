document.addEventListener("turbolinks:load", function() {
    $(document).on("click", ".deck-adjust-button", adjustDeck)
    $(document).on("click", "#decklist-submit", submitDecklist)
    $(document).on("input", "#list-search", updateMiniList)
}) 

function adjustDeck(e) {
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
}

function submitDecklist(e) {
    e.preventDefault()
        
    deck_divs = $(".deck")
    decklist_decks = []
    decklist_name =  $('#name').val()
    decklist_description = $("#description").val()

    deck_divs.each(function(div) {
        deck = $(deck_divs[div])
        deck_name_raw = deck.find('div').attr("id")
        deck_name = deck_name_raw.split("-")[0]
        deck_name = deck_name.charAt(0).toUpperCase() + deck_name.slice(1)
        deck_div = deck.find('#' + deck_name_raw)

        cards_array = []

        deck_div.children().each(function() {
            card_text = $(this).text().trim()
            card_name = card_text.substr(card_text.indexOf(' ')+1)
            card_num = parseInt(card_text.substr(0,card_text.indexOf(' ')).replace(/x/g, ''))
            cards_array.push({
                name: card_name,
                num: card_num,
            })
        })

        decklist_decks.push({
            name: deck_name,
            cards: cards_array
        })

    })

    decklist = {
        decklist: {
            name: decklist_name,
            description: decklist_description,
            decks: decklist_decks
        }
    }

    $.ajax({
        method: "POST",
        url: "/decklists",
        data: decklist
    })
    .done(function( msg ) {
        window.location.replace("/decklists/" + msg.id);
    })
    .fail(function( msg) {
        window.location.replace("/decklists/new");
    })   
}

function updateMiniList(e) {
    inputValue = $(this).val().toLowerCase()
    
    listEntries = $(this).parents().siblings('#mini-card-list').find('tr')

    listEntries.each(function() {
        entry = $(this)
        entryName = $(this).data("name").toLowerCase()

        if (!entryName.includes(inputValue)) {
            entry.hide()
        } else {
            entry.show()
        }
    })

    if(inputValue.length > 2) {
        data = { "name": inputValue }
        ApiCall("POST", "/cards/search", data, appendCards)
    }
}

function ApiCall(method, target, data, callback) {
    $.ajax({
        method: method,
        url: target,
        data: data,
        success: callback
    })
}

function appendCards(cards) {
    cards.forEach(function(card) {
        name = card.name
        
        newCardDiv = $('<tr data-name="' + name + '">\
        <td>\
            <select class="form-control" id="num-cards">\
                <option value=0>0</option>\
                <option value=1>1</option>\
                <option value=2>2</option>\
                <option value=3>3</option>\
                <option value=4>4</option>\
            </select>\
        </td>\n\
        <td>' + name + '</td>\n\
        <td>\
            <div class="btn-group btn-group-sm" role="group">\
                <button type="button" class="btn btn-secondary deck-adjust-button">Main</button>\
                <button type="button" class="btn btn-secondary deck-adjust-button">Stone</button>\
                <button type="button" class="btn btn-secondary deck-adjust-button">Side</button>\
                <button type="button" class="btn btn-secondary deck-adjust-button">Ruler</button>\
            </div>\
        </td>\
        </tr>')

        $('#mini-card-list').find('table').append(newCardDiv)
    });
}

