
function Lib.Dialog.dialogBox.paint(gc,dialogBox,windowID)
    local sizeX,sizeY
    if not dialogBox.size then
        gc:setFont("sansserif","r",10)
        sizeX=Lib.Gui.MultiLineStr.width(gc,dialogBox.layout)+24
        sizeY=Lib.Gui.MultiLineStr.height(gc,dialogBox.layout)+17
        Lib.Dialog._windows[windowID].size={sizeX,sizeY}
    else
        sizeX,sizeY=unpack(dialogBox.size)
    end
    Lib.Dialog._paint_window_bg(gc,dialogBox.name,sizeX,sizeY)
    Lib.Dialog._paint_text_area(gc,dialogBox.layout,sizeX,sizeY)
    Lib.Dialog._paint_buttons(gc,dialogBox.buttons,sizeX,sizeY,windowID)
end

function Lib.Dialog.custom.paint(gc,window,windowID)
    Lib.Dialog._paint_window_bg(gc,window.name,window.size[1],window.size[2])
    Lib.Dialog._paint_layout(gc,window.layout,window.size[1],window.size[2])
    Lib.Dialog._paint_buttons(gc,window.buttons,window.size[1],window.size[2],windowID)
end



function Lib.Dialog._paint_layout(gc,layout,sizeX,sizeY)
    local x,y=(platform.window:width()-sizeX)/2,(platform.window:height()-sizeY-15)/2
    for i,e in pairs(layout) do
        if e[1]=="textBox" then
            Lib.Dialog._paint_text_box(gc,e,x,y,Lib.Dialog.focus==i)
        elseif e[1]=="label" then
            Lib.Dialog._paint_label(gc,e,x,y)
        elseif e[1]=="colorSlider" then
            Lib.Dialog._paint_color_slider(gc,e,x,y,Lib.Dialog.focus==i)
        elseif e[1]=="list" then
            Lib.Dialog._paint_list(gc,e,x,y,Lib.Dialog.focus==i)
        end
    end
end

function Lib.Dialog._paint_label(gc,label,x,y)
    gc:setFont("sansserif","r",10)
    if label.color then
        gc:setColorRGB(0,0,0)
        gc:fillRect(x+label.x,y+label.y,30,20)
        gc:setColorRGB(unpack(label.color))
        gc:fillRect(x+label.x+1,y+label.y+1,28,18)
    else
        gc:setColorRGB(0,0,0)
        gc:drawString(label.text,x+label.x,y+label.y,"top")
    end
end

function Lib.Dialog._paint_text_box(gc,textBox,x,y,selected)
    if gc:getStringWidth(textBox.text)>textBox.sizeX-5 then
        textBox.prev=textBox.prev or {"",0}
        textBox.text,textBox.cursor=unpack(textBox.prev)
    end
    if textBox.setCursor then
        textBox.cursor=string.len(textBox.text)
        for i=string.len(textBox.text),1,-1 do
            if gc:getStringWidth(string.sub(textBox.text,1,i))>textBox.setCursor then
                textBox.cursor=i-1
            end
        end
        textBox.setCursor=nil
    end
    if selected then
        gc:setColorRGB(50,150,190)
        gc:fillRect(x+textBox.x-2,y+textBox.y-2,textBox.sizeX+5,27)
    end
    gc:setColorRGB(255,255,255)
    gc:fillRect(x+textBox.x,y+textBox.y,textBox.sizeX,22)
    gc:setColorRGB(0,0,0)
    gc:drawRect(x+textBox.x,y+textBox.y,textBox.sizeX-1,22)
    gc:setFont("sansserif","r",10)
    gc:drawString(textBox.text,x+textBox.x+3,y+textBox.y+1,"top")
    if selected then
        gc:fillRect(gc:getStringWidth(string.usub(textBox.text,1,textBox.cursor))+x+textBox.x+3,y+textBox.y+2,1,19)
    end
end

function Lib.Dialog._paint_color_slider(gc,slider,x,y,selected)
    if selected then
        gc:setColorRGB(50,150,190)
        gc:fillRect(x+slider.x-2,y+slider.y-2,72,24)
    end
    gc:setColorRGB(0,0,0)
    gc:fillRect(x+slider.x,y+slider.y,68,20)
    for i=0,63 do
        gc:setColorRGB(slider.color=="red" and i*4 or newColor[1],slider.color=="green" and i*4 or newColor[2],slider.color=="blue" and i*4 or newColor[3])
        gc:fillRect(x+slider.x+i+2,y+2+slider.y,1,16)
    end
    if platform.isColorDisplay() then
        gc:setColorRGB(255-slider.value,255-slider.value,255-slider.value)
    else
        gc:setColorRGB(255,255,255)
    end
    gc:fillRect(x+slider.x+slider.value/4+1,y+slider.y-2,3,24)
end

function Lib.Dialog._paint_list(gc,list,x,y,selected)
    if selected then
        gc:setColorRGB(50,150,190)
        gc:fillRect(x+list.x-2,y+list.y-2,list.sizeX+4,list.sizeY+4)
    end
    gc:setColorRGB(0,0,0)
    gc:fillRect(list.x+x,list.y+y,list.sizeX,list.sizeY)
    gc:setColorRGB(255,255,255)
    gc:fillRect(list.x+1+x,list.y+1+y,list.sizeX-2,list.sizeY-2)
    gc:setColorRGB(100,100,100)
    gc:drawImage(Lib.Dialog._img.upButton,list.x+x+list.sizeX-14,y+list.y+3)
    gc:drawImage(Lib.Dialog._img.downButton,list.x+x+list.sizeX-14,y+list.y+list.sizeY-13)
    gc:drawRect(list.x+x+list.sizeX-14,y+list.y+15,10,list.sizeY-31)
    gc:setFont("sansserif","r",10)
    local fontHeight=list.fontHeight
    if not fontHeight then
        list.fontHeight=gc:getStringHeight("a")
        fontHeight=list.fontHeight
    end
    local capacity=math.floor(list.sizeY/fontHeight)
    if list.selected<list.scroll+1 then
        list.scroll=list.selected-1
    elseif list.selected>list.scroll+capacity then
        list.scroll=list.selected-capacity
    end
    if list.scroll>#list.elements-capacity then
        local scroll=#list.elements-capacity
        scroll=scroll<0 and 0 or scroll
        list.scroll=scroll
    end
    if #list.elements*fontHeight>list.sizeY then
        local scrollBarSize=(list.sizeY-31)*list.sizeY/(#list.elements*fontHeight)
        gc:fillRect(list.x+x+list.sizeX-14,y+list.y+15+list.scroll*(list.sizeY-31)/#list.elements,11,scrollBarSize)
    end
    gc:setColorRGB(0,0,0)
    local step=0
    for i=list.scroll+1,list.scroll+capacity do
        if list.elements[i] then
            if list.selected==i then
                gc:setColorRGB(unpack(selected and {50,150,190} or {200,200,200}))
                gc:fillRect(list.x+x+1,list.y+y+step*fontHeight+1,list.sizeX-16,fontHeight-2)
                gc:setColorRGB(0,0,0)
            end
            gc:drawString(list.elements[i],list.x+x+3,list.y+y+step*fontHeight,"top")
            step=step+1
        end
    end
end

function Lib.Dialog._paint_buttons(gc,buttons,sizeX,sizeY,windowID)
    local x,y=(platform.window:width()-sizeX)/2,(platform.window:height()-sizeY-15)/2
    gc:setFont("sansserif","r",10)
    if (not buttons[1].size) or Lib.Dialog._resized then
        local totalSize,size,pos=-7,{},{}
        for i,e in pairs(buttons) do
            size[i]=gc:getStringWidth(e[1])+10
            totalSize=totalSize+size[i]+7
        end
        pos[1]=(platform.window:width()-totalSize)/2
        for i=2,#buttons do
            pos[i]=pos[i-1]+size[i-1]+7
        end
        for i,e in pairs(buttons) do
            Lib.Dialog._windows[windowID].buttons[i].size=size[i]
            Lib.Dialog._windows[windowID].buttons[i].pos=pos[i]
        end
        buttons=Lib.Dialog._windows[windowID].buttons
    end
    for i,e in pairs(buttons) do
        gc:setColorRGB(136,136,136)
        gc:fillRect(e.pos,y+sizeY+9,e.size,23)
        gc:fillRect(e.pos+1,y+sizeY+8,e.size-2,25)
        gc:fillRect(e.pos+2,y+sizeY+7,e.size-4,27)
        gc:setColorRGB(255,255,255)
        gc:fillRect(e.pos+2,y+sizeY+9,e.size-4,23)
        gc:setColorRGB(0,0,0)
        gc:drawString(e[1],e.pos+5,y+sizeY+20,"middle")
    end
    if Lib.Dialog.focus<0 and windowID==Lib.Dialog.NbWindows() then
        local button=buttons[-Lib.Dialog.focus]
        if platform.isColorDisplay() then
            gc:setColorRGB(50,150,190)
        else
            gc:setColorRGB(0,0,0)
        end
        gc:drawRect(button.pos-3,y+sizeY+4,button.size+5,32)
        gc:drawRect(button.pos-2,y+sizeY+5,button.size+3,30)
    end
end

function Lib.Dialog._paint_text_area(gc,text,sizeX,sizeY)
    local x,y=(platform.window:width()-sizeX)/2,(platform.window:height()-sizeY-15)/2
    if platform.isColorDisplay() then
        gc:setColorRGB(128,128,128)
    else
        gc:setColorRGB(255,255,255)
    end
    gc:drawRect(x+6,y+6,sizeX-13,sizeY-13)
    gc:setColorRGB(0,0,0)
    gc:setFont("sansserif","r",10)
    Lib.Gui.MultiLineStr.draw(gc,text,x+12,y+9)
end

function Lib.Dialog._paint_window_bg(gc,name,sizeX,sizeY)
    local x,y=(platform.window:width()-sizeX)/2,(platform.window:height()-sizeY-15)/2
    if platform.isColorDisplay() then
        gc:setColorRGB(100,100,100)
    else
        gc:setColorRGB(200,200,200)
    end
    gc:fillRect(x-1,y-23,sizeX+4,sizeY+65)
    gc:fillRect(x,y-22,sizeX+4,sizeY+65)
    gc:fillRect(x+1,y-21,sizeX+4,sizeY+65)
    if platform.isColorDisplay() then
        gc:setColorRGB(128,128,128)
    else
        gc:setColorRGB(0,0,0)
    end
    gc:fillRect(x-2,y-24,sizeX+4,sizeY+65)
    if platform.isColorDisplay() then
        for i=1,22 do
            gc:setColorRGB(32+i*3,32+i*3,32+i*3)
            gc:fillRect(x,y+i-23,sizeX,1)
        end
    else
        gc:setColorRGB(0,0,0)
        gc:fillRect(x,y-22,sizeX,22)
    end
    gc:setColorRGB(255,255,255)
    gc:setFont("sansserif","r",10)
    gc:drawString(name,x+4,y-9,"baseline")
    gc:setColorRGB(224,224,224)
    gc:fillRect(x,y,sizeX,sizeY+39)
    gc:setColorRGB(128,128,128)
    gc:fillRect(x+6,y+sizeY,sizeX-12,2)
end
