function addToggles(sectionNames) {
    for (var i = 0; i < sectionNames.length; i++) {
        header = document.getElementById(sectionNames[i] + "-header")
        if (header != null) {
            header.addEventListener('click', addToggleFunction(sectionNames[i]))
        }
    }
}

function addToggleFunction(n) {
    var sectionName = n
    return function() {
        var header = document.getElementById(sectionName + "-header")
        var arrow = document.getElementById(sectionName + "-arrow")
        var list = document.getElementById(sectionName + "-list")
        if (header.classList.contains("closed")) {
            arrow.classList.remove("inverted")
            header.classList.remove("closed")
            expandSection(list)
        } else {
            arrow.classList.add("inverted")
            header.classList.add("closed")
            collapseSection(list)
        }
    }
}

// collapseSection and expandSection courtesy of Brandon Smith
// https://css-tricks.com/using-css-transitions-auto-dimensions/
// Thankfully, https://css-tricks.com/license/ is quite permissive
function collapseSection(element) {
  var sectionHeight = element.scrollHeight;

  var elementTransition = element.style.transition;
  element.style.transition = '';

  requestAnimationFrame(function() {
    element.style.height = sectionHeight + 'px';
    element.style.transition = elementTransition;

    requestAnimationFrame(function() {
      element.style.height = 0 + 'px';
    });
  });
}

function expandSection(element) {
  var sectionHeight = element.scrollHeight;

  element.style.height = sectionHeight + 'px';
  element.addEventListener('transitionend', function(e) {
    element.removeEventListener('transitionend', arguments.callee);

    element.style.height = null;
  });
}

function getPanelTemplate(name, readableName, mix = null) {
    return `<div class="item-header" id="${name}-header">
        <h2>${readableName}</h2>
        <img class="arrow" id="${name}-arrow" src="assets/arrow.svg" />
    </div>
    <div class="item-container" id="${name}-list">${mix}</div>`
}

function getItemTemplate(symbol, name, desc, color = "var(--text)") {
    return `<div class="item">
        <div class = "item-icon-container" style="background-color: ${color}">
            <span class="item-icon">${symbol}</span>
        </div>
        <div class = "item-contents">
            <div class = "item-title">${name}</div>
            <div class = "item-desc">${desc}</div>
        </div>
    </div>`
}

var sections = document.getElementsByClassName("section")
var names = [];
var readableNames = [];
for (var i = 0; i < sections.length; i++) {
    var section = sections[i]
    names.push(section.getAttribute('id'))
    readableNames.push(section.getAttribute('name'))

    var mix = section.innerHTML
    section.innerHTML = getPanelTemplate(names[i],readableNames[i], mix)
}

addToggles(names)
