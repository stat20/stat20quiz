
function makeTF(doc)
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
    
    quarto.log.output(">>>", doc.blocks)

    return doc
end


function makeQuestionsEnv(doc)
    -- Wrap doc in questions environment
    if FORMAT:match 'latex' then
        -- LaTeX commands to start and end the questions environment
        local beginQuestions = '\\begin{questions}\n'
        local endQuestions = '\\end{questions}\n'

        -- Insert the beginQuestions command at the start of the document
        table.insert(doc.blocks, 1, pandoc.RawBlock('latex', beginQuestions))
        -- Append the endQuestions command at the end of the document
        table.insert(doc.blocks, pandoc.RawBlock('latex', endQuestions))
    end
    
    quarto.log.output(">>>", doc.blocks)
    
    return doc
end

function makeMC(list)
    local blocks = {}
    
    -- Add the beginning of the checkboxes environment
    table.insert(blocks, pandoc.RawBlock('latex', '\\begin{checkboxes}'))
    
    for _, item in ipairs(list.content) do
        -- Start with the \choice command for each list item
        local choicePrefix = pandoc.RawInline('latex', '\\choice ')
        
        -- Initialize the paragraph content with the choicePrefix
        local paraContent = {choicePrefix}

        -- Assuming each item contains a list of inline elements or single blocks that need to be handled
        for _, block in ipairs(item) do
            if block.t == 'Plain' or block.t == 'Para' then
                for _, inline in ipairs(block.content) do
                    table.insert(paraContent, inline)
                end
            end
        end
        
        local para = pandoc.Para(paraContent)
        table.insert(blocks, para)
    end
    
    -- Add the end of the checkboxes environment
    table.insert(blocks, pandoc.RawBlock('latex', '\\end{checkboxes}'))
    
    return blocks
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

