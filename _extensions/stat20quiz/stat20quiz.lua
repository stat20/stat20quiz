
function makeQuestions(doc)
    -- Convert ## to appropriate latex
    local blocks = {} -- New table to hold the modified list of blocks
    local i = 1
    local firstQInd = 1

    while i <= #doc.blocks do
        local block = doc.blocks[i]
        if block.t == "Header" and block.level == 2 then
            -- log which block has the first question
            if firstQInd == 1 then
                firstQInd = i
            end
              
            local latexString
            if block.classes:includes('tf') then
                --latexString = "\\question \\rule{1.5cm}{0.15mm}"
                latexString = "\\question \\begin{tikzpicture}[baseline={([yshift=-.7ex]circle.center)}] \n \\node[draw,circle,inner sep=0pt,minimum size=3mm] (circle) {}; \n \\node at (circle.center) {\\fontsize{2.5mm}{3mm}\\selectfont T}; \n \\end{tikzpicture}\n \\begin{tikzpicture}[baseline={([yshift=-.7ex]circle.center)}] \n \\node[draw,circle,inner sep=0pt,minimum size=3mm] (circle) {}; \n \\node at (circle.center) {\\fontsize{2.5mm}{3mm}\\selectfont F}; \n \\end{tikzpicture}"
            elseif block.classes:includes('select-all') then
                latexString = "\\checkboxchar{$\\Box$}\n \\question"
            else
                latexString = "\\checkboxchar{$\\bigcirc$}\n \\question"
            end

            -- Look for the next Para block or the next level two header
            local foundPara = false
            for j = i+1, #doc.blocks do
                if doc.blocks[j].t == "Para" then
                    -- Prepend LaTeX command to the Para block content
                    table.insert(doc.blocks[j].content, 1, pandoc.RawInline('latex', latexString .. " "))
                    foundPara = true
                    break -- Stop after modifying the first Para block found
                elseif doc.blocks[j].t == "Header" and doc.blocks[j].level == 2 then
                    break -- Stop the search if another level 2 header is encountered
                end
            end

            -- If no Para block was found before the next level two header, insert a new Para
            if not foundPara then
                table.insert(blocks, pandoc.Para{pandoc.RawInline('latex', latexString)})
            end
        else
            -- Add all non-header blocks to the output list
            table.insert(blocks, block)
        end
        i = i + 1
    end

    -- Replace the original document blocks with the modified list
    doc.blocks = blocks

    return doc, firstQInd
end


function makeQuestionsEnv(doc, startInd)
    -- Wrap doc in questions environment
    local beginQuestions = '\\begin{questions}\n'
    local endQuestions = '\\end{questions}\n'

    table.insert(doc.blocks, startInd, pandoc.RawBlock('latex', beginQuestions))
    table.insert(doc.blocks, pandoc.RawBlock('latex', endQuestions))
    
    return doc
end


function makeMC(list)
    local blocks = {}
    -- track number of column breaks
    local nCB = 0
    
    for _, item in ipairs(list.content) do
        local choicePrefix = pandoc.RawInline('latex', '\\choice ')
        local plainContent = {choicePrefix}
        local hasCB, startingInd = hasColBreak(item)
        
        if hasCB then
            -- only copy up to CB delimiter
            copyInlines(item, plainContent, startingInd)
        else
            copyInlines(item, plainContent)
        end
        
        table.insert(blocks, pandoc.Plain(plainContent))
        
        if hasCB then
            table.insert(blocks, pandoc.RawBlock('latex', '\\columnbreak'))
            nCB = nCB + 1
        end
    end
    
    if nCB > 0 then
        multiColStr = '\\begin{multicols}{' .. nCB + 1 .. '}'
        table.insert(blocks, 1, pandoc.RawBlock('latex', multiColStr))
        table.insert(blocks, pandoc.RawBlock('latex', '\\end{multicols}'))
    end

    
    table.insert(blocks, 1, pandoc.RawBlock('latex', '\\begin{checkboxes}'))
    table.insert(blocks, pandoc.RawBlock('latex', '\\end{checkboxes}'))
    
    return blocks
end


function hasColBreak(item)
    local colBreakParts = 0
    local partsInd = 0
    local startingInd = nil
    
    for _, inline in ipairs(item[1].content) do

        if inline.t == 'SoftBreak' then
          colBreakParts = 1
          partsInd = _
          startingInd = _
        end
            
        if colBreakParts == 1 and _ == partsInd + 1 and inline.t == 'Str' and inline.text == '*' then
          colBreakParts = 2
          partsInd = _
        end
            
        if colBreakParts == 2 and _ == partsInd + 1 and inline.t == 'Space' then
          colBreakParts = 3
          partsInd = _
        end

        if colBreakParts == 3 and _ == partsInd + 1 and inline.t == 'Str' and inline.text == '*' then
          colBreakParts = 4
          partsInd = _
        end
            
        if colBreakParts == 4 and _ == partsInd + 1 and inline.t == 'Space' then
          colBreakParts = 5
          partsInd = _
        end

        if colBreakParts == 5 and _ == partsInd + 1 and inline.t == 'Str' and inline.text == '*' then
          return true, startingInd
        end
    end
    
    return false, nil
end

function copyInlines(item, plainContent, stopAt)
    for _, inline in ipairs(item[1].content) do
        if stopAt ~= nil and stopAt == _ then
          break
        else
          table.insert(plainContent, inline)
        end
    end
end

function makeDirBox(el)
    if el.classes:includes('testversions') then
      quarto.log.output(">>> ", el)
    end
  
  
    if el.classes:includes('directionsbox') then
        local width = "5.5in" -- Default width

        if el.attributes.width then
            width = el.attributes.width
        end
        
        --local latexStart = "\\begin{center}\n\\fbox{\\parbox{" .. width .. "}{\\centering\n"
        local latexStart = "\\begin{center}\n\\fbox{\\centering\n"
        local latexEnd = "}\n\\end{center}"
        
        table.insert(el.content, 1, pandoc.RawBlock('latex', latexStart))
        table.insert(el.content, pandoc.RawBlock('latex', latexEnd))

        return el
    end
    
    return el
end

function addHeader(doc)
  -- set defaults
  local nNames = 1
  local titleStr = ''
  local versionStr = ''
  
  -- get meta data
  if doc.meta['n-names'] then
    nNames = doc.meta['n-names'][1].text
  end
  
  if doc.meta['title'] then
    titleStr = inlinesToString(doc.meta['title'])
  end
  
  if doc.meta['version'] then
    versionStr = doc.meta['version'][1].text
  end
  
  -- create header content
  local namesStr = string.rep('\\textsc{Name}: \\fbox{\\makebox[3.5cm]{\\strut}}', nNames, ' \\quad')
  local headerStr = namesStr .. '\\hfill ' .. titleStr .. ' \\, {\\Large ' .. versionStr .. '}'
  
  -- add header content
  table.insert(doc.blocks, 1, pandoc.RawBlock('latex', headerStr))
  
  -- add horizontal rule
  local hRuleStr = '\\noindent\\rule{17.5cm}{0.4pt}\n\\vspace{2mm}'
  table.insert(doc.blocks, 2, pandoc.RawBlock('latex', hRuleStr))
  
  -- remove title block
  --table.insert(doc.blocks, 1, pandoc.RawBlock('latex', '\\pagestyle{empty}'))
  
  return doc
end

function inlinesToString(inlines)
    local textParts = {}
    for _, inline in ipairs(inlines) do
        if inline.text then
            table.insert(textParts, inline.text)
        elseif inline.t == "Space" then
            table.insert(textParts, " ")
        end
    end
    return table.concat(textParts)
end

function filterVersions(span)
  if versionMeta == nil then
    versionMeta = 'ZZQ'
  end
  
  if hasVersionClass(span) then
     if not span.classes:includes('v' .. versionMeta) then
       return pandoc.Span({})
     end
  end
  return span
end

function hasVersionClass(element)
    for _, class in ipairs(element.classes) do
        if class:match("^v[A-Z]$") then
            return true
        end
    end
    return false
end

function getVersion(meta)
  if meta.version then
    versionMeta = meta.version[1].text
  end
end



function makeQuiz(doc)
    -- Turn ## into \question
    doc, firstQInd = makeQuestions(doc)
    
    -- Wrap the document in a questions environment
    doc = makeQuestionsEnv(doc, firstQInd)
    
    doc = addHeader(doc)
    
    return doc
end


return {
  {Meta = getVersion},
  {Span = filterVersions,
  Div = makeDirBox,
  BulletList = makeMC,
  Pandoc = makeQuiz}
}

