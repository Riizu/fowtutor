$(document).on("click", ".deck-adjust-button", adjustDeck)
$(document).on("click", ".decklist-remove-card", removeCard)
$(document).on("click", "#decklist-submit", submitDecklist)

function adjustDeck(e) {
    card_name = ""
    $(this).parents('td').siblings().each(function() {
        if($(this).text() != null && $(this).attr("class") == null) {
            card_name = $(this).text()
        }
    });

    card_name_sanitized = card_name.replace(/\s+/g, '-').replace(/,/g, '').replace(/'/g, '').replace(/\"/g,'\\"') .toLowerCase();
    num_cards = $(this).parents('tr').find("#num-cards").val() 
    deck = $(this).text().toLowerCase() + "-deck"
    console.log(card_name + "|" + num_cards + "|" + deck)

    deck_div = $("#" + deck)
    deck_div.find("#" + card_name_sanitized).parent('div').remove()

    if (parseInt(num_cards) > 0) {
        card_div = $("<div></div").appendTo(deck_div)
        $("<button type='button' class='btn btn-default decklist-remove-card'><i class='fa fa-times'></i></button>").appendTo(card_div)
        $("<span id=" + card_name_sanitized + ">" + num_cards + "x " + card_name + "</span>").appendTo(card_div)
    }

    new_total = countCards(deck_div)
    updateCardCount(deck_div, new_total)
    
}

function removeCard(e) {
    deck_div = $(this).parents('div')[1]
    current_total = countCards(deck_div)
    amount_to_remove = parseInt($(this).siblings('span')[0].innerText.split(" ", 1)[0].replace("x", ""))
    remaining = current_total - amount_to_remove
    updateCardCount(deck_div, remaining)
    $(this).closest('div').remove()
    
}

function countCards(deck_div) {
    unique_cards = $(deck_div).find('span')
    total = 0

    unique_cards.each(function() {
        card = $(this)[0]
        amount = parseInt(card.innerText.split(" ", 1)[0].replace("x", ""))
        total += amount
    })

    return total
}

function updateCardCount(deck_div, count) {
    deck_name = $(deck_div).attr('id').split("-", 1)[0]
    deck_name_capitalized = deck_name.charAt(0).toUpperCase() + deck_name.slice(1)
    $(deck_div).parent('.deck').find('h4')[0].innerText = deck_name_capitalized + "(" + count + ")"
}

function submitDecklist(e) {
    e.preventDefault()
        
    submission_target = $(this).val().toLowerCase()

    if(submission_target.includes("update")) {
        submission_target = "PATCH"
        fail_target = "/decklists/edit"
        base_url = window.location.pathname.split("/")
        id = base_url[base_url.length-2]
        url = "/decklists/" + id
        fail_target = "/decklists/" + id + "/edit"
    } else {
        submission_target = "POST"
        url = "/decklists"
        fail_target = "/decklists/new"
    }

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
        method: submission_target,
        url: url,
        data: decklist
    })
    .done(function( msg ) {
        window.location.replace("/decklists/" + msg.id);
    })
    .fail(function( msg) {
        window.location.replace(fail_target);
    })   
}
