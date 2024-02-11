
function makeTF(doc)
    --quarto.log.output(">>>", doc.blocks)
    -- Convert ## to appropriate latex
    local blocks = {} -- New table to hold the modified list of blocks
    local i = 1 -- Iterator for the while loop

    while i <= #doc.blocks do
        local block = doc.blocks[i]
        if block.t == "Header" and block.level == 2 then
            -- Determine the LaTeX string based on the header class
            local latexString
            if block.classes:includes('tf') then
                latexString = "\\question \\rule{1.5cm}{0.15mm}"
            else
                latexString = "\\question"
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

            -- Skip adding the current header to 'blocks' to remove it
        else
            -- Add all non-header blocks to the output list
            table.insert(blocks, block)
        end
        i = i + 1
    end

    -- Replace the original document blocks with the modified list
    doc.blocks = blocks

    return doc
end


function makeQuestionsEnv(doc)
    -- Wrap doc in questions environment
    if FORMAT:match 'latex' then
        -- LaTeX commands to start and end the questions environment
        local beginQuestions = '\\begin{questions}\n'
        local endQuestions = '\\end{questions}\n'

        table.insert(doc.blocks, 1, pandoc.RawBlock('latex', beginQuestions))
        table.insert(doc.blocks, pandoc.RawBlock('latex', endQuestions))
    end
    
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



function makeQuiz(doc)
    -- Apply transformations for true/false questions
    doc = makeTF(doc)
    
    -- Wrap the document in a questions environment
    doc = makeQuestionsEnv(doc)
    
    return doc
end


return {
  BulletList = makeMC,
  Pandoc = makeQuiz
}

