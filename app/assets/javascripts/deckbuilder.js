$(document).on("click", ".deck-adjust-button", adjustDeck)
$(document).on("click", ".decklist-remove-card", removeCard)
$(document).on("click", "#decklist-submit", submitDecklist)

function populateDecklist() {
    if (localStorage.getItem('decklist') !== 'null') {
        decklist = JSON.parse(localStorage.getItem('decklist'))
        console.log(decklist)
        decklist_name =  $('#name')
        decklist_tags = $('#tag_list')
        decklist_description = $("#description")

        $(decklist_name).val(decklist.name)
        $(decklist_tags).val(decklist.tag_list)
        $(decklist_description).val(decklist.description)

        if (decklist.decks !== null) {
            decklist.decks.forEach(function(deck) {
                deck_name = deck.name.toLowerCase() + "-deck"
                deck_div = $('#' + deck_name)
        
                deck.cards.forEach(function(card) {
                    card_div = $("<div></div").appendTo(deck_div)
                    $("<button type='button' class='btn btn-default decklist-remove-card'><i class='fa fa-times'></i></button>").appendTo(card_div)
                    $("<span id=" + card.code + ">" + card.text + "</span>").appendTo(card_div)
                })
            })
        }    
    }
}

function countDecks() {
    deck_names = ["ruler-deck", "main-deck", "stone-deck", "side-deck"]
    deck_names.forEach(function(name) {
        deck_div = "#" + name
        count = countCards(deck_div)
        updateCardCount(deck_div, count)
    })
}

function adjustDeck(e) {
    card_name = ""
    card_code = ""
    $(this).parents('td').siblings().each(function() {
        if($(this).text() != null && $(this).attr("class") == null) {
            card_name = $(this).text()
        }

        if($(this).attr("class") == "sorting_1") {
            card_code = $(this).text()
        }
    });

    num_cards = $(this).parents('tr').find("#num-cards").val() 
    deck = $(this).text().toLowerCase() + "-deck"
    console.log(card_code + "|" + card_name + "|" + num_cards + "|" + deck)

    deck_div = $("#" + deck)
    deck_div.find("#" + card_code).parent('div').remove()

    if (parseInt(num_cards) > 0) {
        card_div = $("<div></div").appendTo(deck_div)
        $("<button type='button' class='btn btn-default decklist-remove-card'><i class='fa fa-times'></i></button>").appendTo(card_div)
        $("<span id=" + card_code + ">" + num_cards + "x " + card_name + " (" + card_code +")</span>").appendTo(card_div)
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
    e.preventDefault();
    submission_target = $('#decklist-submit').val().toLowerCase();

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
    decklist_tags = $('#tag_list').val()
    decklist_description = $("#description").val()

    deck_divs.each(function(div) {
        deck = $(deck_divs[div])
        deck_name_raw = deck.find('div').attr("id")
        deck_name = deck_name_raw.split("-")[0]
        deck_name = deck_name.charAt(0).toUpperCase() + deck_name.slice(1)
        deck_div = deck.find('#' + deck_name_raw)

        cards_array = []

        deck_div.children().each(function() {
            card_code = $(this).find('span').attr('id')
            card_text = $(this).text().trim()
            card_num = parseInt(card_text.substr(0,card_text.indexOf(' ')).replace(/x/g, ''))
            cards_array.push({
                code: card_code,
                num: card_num,
                text: card_text
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
            decks: decklist_decks,
            tag_list: decklist_tags
        }
    }
    
    if (submission_target == "POST") {
        localStorage.setItem("decklist", JSON.stringify(decklist.decklist))
    }

    $.ajax({
        method: submission_target,
        url: url,
        data: decklist
    })
    .done(function( msg ) {
        localStorage.setItem("decklist", null)
        window.location.replace("/decklists/" + msg.id);
    })
    .fail(function( msg) {
        window.location.replace(fail_target);
    })
}
