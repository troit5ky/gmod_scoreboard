local scoreboard = scoreboard or {}

-- vars

local padding = ScreenScale( 10 )
local innerPadding = padding/2
local cardSize = ScreenScale( 23 )
local micIcon = Material( 'icon16/sound.png' ) 
local micMutedIcon = Material( 'icon16/sound_mute.png' ) 

--

-- colors

local white = Color( 255, 255, 255, 255 )
local grey = Color(38, 38, 38, 248)

--

-- funcs

local draw_RoundedBox = draw.RoundedBox
local team_GetName = team.GetName
local team_GetColor= team.GetColor
local string_format = string.format
local string_FormattedTime = string.FormattedTime
local player_GetAll = player.GetAll
local math_rad = math.rad
local math_Clamp = math.Clamp
local math_cos = math.cos
local math_sin = math.sin
local surface_SetDrawColor = surface.SetDrawColor
local surface_DrawPoly = surface.DrawPoly
local surface_SetMaterial = surface.SetMaterial
local surface_DrawTexturedRect = surface.DrawTexturedRect 
local player_GetCount = player.GetCount
local game_MaxPlayers = game.MaxPlayers
local IsValid = IsValid

--

do -- by chmilhane/circularavatar.lua
    local PANEL = {}

    function PANEL:Init()
      self.base = vgui.Create("AvatarImage", self)
      self.base:Dock(FILL)
      self.base:SetPaintedManually(true)
      self:SetMouseInputEnabled(false)
    end
    
    function PANEL:GetBase()
      return self.base
    end
    
    function PANEL:PushMask(mask)
      render.ClearStencil()
      render.SetStencilEnable(true)
    
      render.SetStencilWriteMask(1)
      render.SetStencilTestMask(1)
    
      render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
      render.SetStencilPassOperation(STENCILOPERATION_ZERO)
      render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
      render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)
      render.SetStencilReferenceValue(1)
    
      mask()
    
      render.SetStencilFailOperation(STENCILOPERATION_ZERO)
      render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
      render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
      render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
      render.SetStencilReferenceValue(1)
    end
    
    function PANEL:PopMask()
      render.SetStencilEnable(false)
      render.ClearStencil()
    end
    
    function PANEL:Paint(w, h)
      self:PushMask(function()
        local poly = {}
    
        local x, y = w / 2, h / 2
        for angle = 1, 360 do
          local rad = math_rad(angle)
    
          local cos = math_cos(rad) * y
          local sin = math_sin(rad) * y
    
          poly[#poly + 1] = {
            x = x + cos,
            y = y + sin
          }
        end
    
        draw.NoTexture()
        surface_SetDrawColor(white)
        surface_DrawPoly(poly)
      end)
        self.base:PaintManual()
      self:PopMask()
    end
    
    vgui.Register("space.scoreboard.avatar", PANEL)

end

do 

    local PANEL = {}

    AccessorFunc( PANEL, 'material', 'Material')

    function PANEL:Init()
        
    end

    function PANEL:Paint( w,h )
    
    surface_SetDrawColor( white )
    surface_SetMaterial( self:GetMaterial() )
    surface_DrawTexturedRect( 0, 0, w, h )

    end

    vgui.Register( 'space.scoreboard.icon', PANEL, 'EditablePanel' )

end

do 

    local PANEL = {}

    function PANEL:Init()

        self:Dock( TOP )

        local hostname = GetHostName()

        local title = vgui.Create( 'DLabel', self )
        title:SetFont( 'space.scoreboard.font.title' )
        title:SetTextColor( white )
        title:SetText( hostname )
        title:SetContentAlignment( 5 )
        title:SizeToContents()
        title:Dock( TOP )

        self.subtitle = vgui.Create( 'DLabel', self )
        local subtitle = self.subtitle
        subtitle:SetFont( 'space.scoreboard.font' )
        subtitle:SetTextColor( white )
        subtitle:SetContentAlignment( 5 )
        subtitle:SizeToContents()
        subtitle:Dock( TOP )

        surface.SetFont( "space.scoreboard.font.title" )
        local _, th = surface.GetTextSize( hostname )
        local _, sh = surface.GetTextSize( 'Игроков на сервере %s из %s' )

    end

    function PANEL:PerformLayout(w,h)

        local totalSize = 0

        for _, child in ipairs( self:GetChildren() ) do
            
            _, h = child:GetSize()

            totalSize = totalSize + h

        end

        self:SetSize( w, totalSize )

        self:Dock( TOP )
        
    end

    function PANEL:Think()
        local players = string_format( 'Игроков на сервере %s из %s', player_GetCount(), game_MaxPlayers() )

        self.subtitle:SetText( players )
    end
    
    function PANEL:Paint()
    end

    vgui.Register( 'space.scoreboard.header', PANEL, 'EditablePanel' )

end

do 

    local PANEL = {}

    function PANEL:Init()

        self:Dock( FILL )
        self:SetMouseInputEnabled(false)

    end

    function PANEL:PerformLayout( w,h )

        local count = self:ChildCount()
        local pSize, _ = self:GetSize()

        for _, child in ipairs( self:GetChildren() ) do
            
            child:SetSize( pSize / count, 0 )
            child:Dock( LEFT )

        end

    end

    vgui.Register( 'space.scoreboard.row', PANEL, 'EditablePanel' )

end

do 

    local PANEL = {}

    AccessorFunc( PANEL, 'data', 'Data' )

    function PANEL:Init()

        self:SetCursor( 'hand' )
        
        self.title = vgui.Create( 'DLabel', self )
        self.title:SetColor(white)
        self.title:SetFont( 'space.scoreboard.font' )
        self.title:SetContentAlignment( 5 )

        self.sub = vgui.Create( 'DLabel', self )
        self.sub:SetColor(white)
        self.sub:SetFont( 'space.scoreboard.font' )
        self.sub:SetContentAlignment( 5 )


    end

    function PANEL:PerformLayout()
        local data = self:GetData() or {}

        self.sub:SetText( data[2] or '' )
        self.sub:SetColor( data[3] or white )
        self.sub:SizeToContents( 2 )
        self.sub:Dock( TOP )

        self.title:SetText( data[1] or '' )
        self.title:SizeToContents( 2 )
        self.title:Dock( BOTTOM )

    end

    vgui.Register( 'space.scoreboard.column', PANEL, 'EditablePanel' )

end

do 

    local PANEL = {}

    function PANEL:Init()

        self.color = Color( white.r, white.g, white.b, 5 )

        self:SetSize(0, cardSize)
        self:Dock( TOP )
        self:DockPadding( innerPadding, innerPadding, innerPadding, innerPadding )
        self:SetCursor( 'hand' )

        self.avatar = vgui.Create( 'space.scoreboard.avatar', self )
        self.avatar:SetSize(cardSize - padding, 0)
        self.avatar:Dock( LEFT )

        self.nickLabel = vgui.Create( 'DLabel', self )
        self.nickLabel:SetColor( white )
        self.nickLabel:SetFont( 'space.scoreboard.font' )
        self.nickLabel:Dock( LEFT )
        self.nickLabel:DockMargin( innerPadding, 0, 0, 0 )

        local row = vgui.Create( 'space.scoreboard.row', self )
        row:Dock( FILL )

        self.roleColumn = vgui.Create( 'space.scoreboard.column', row  )
        self.timeColumn = vgui.Create( 'space.scoreboard.column', row  )
        self.fragsColumn = vgui.Create( 'space.scoreboard.column', row  )
        self.deathsColumn = vgui.Create( 'space.scoreboard.column', row  )

        self.mic = vgui.Create( 'space.scoreboard.icon', self )
        self.mic:SetCursor( 'hand' )
        self.mic:SetMaterial( micIcon )
        self.mic:SetSize( cardSize - padding )
        self.mic:Dock( RIGHT )
        self.mic:DockMargin( innerPadding, 0, 0, 0 )
        function self.mic:OnMousePressed()

            if self.ply:IsMuted() then self.ply:SetMuted( false ) else self.ply:SetMuted( true ) end
        
        end

        self.pingLabel = vgui.Create( 'DLabel', self )
        self.pingLabel:SetColor( white )
        self.pingLabel:SetFont( 'space.scoreboard.font' )
        self.pingLabel:SetContentAlignment( 6 )
        self.pingLabel:Dock( RIGHT )
        self.pingLabel:DockMargin( 0, 0, 0, 0 )

    end

    function PANEL:Paint( w,h )

        if self:IsHovered() or self:IsChildHovered() then 

            if self.color['a'] != 8 then self.color['a'] = Lerp( .3, self.color['a'], 8 ) end

        else
            if self.color['a'] != 3 then self.color['a'] = Lerp( .3, self.color['a'], 3 ) end 
        end

        draw_RoundedBox( padding, 0, 0, w, h, self.color )
    
    end

    function PANEL:Think()
        
        if !IsValid( self.ply ) then 
            self:Remove()
            
            return
        end

    end

    function PANEL:SetData( ply, size )

        local sizew, _ = self:GetSize()

        self.nickLabel:SetText( ply:Nick() )
        
        local team = ply:Team()
        local ping = ply:Ping()
        local time = string_FormattedTime( ply:GetUTimeTotalTime() )

        self.roleColumn:SetData( { 'Группа', team_GetName( team ), team_GetColor( team ) })
        self.timeColumn:SetData( { 'Наигранно', string_format( '%sч %sм %sс ', time.h, time.m, time.s ) } )
        self.fragsColumn:SetData( { 'Убийств', ply:Frags() } )
        self.deathsColumn:SetData( { 'Смертей', ply:Deaths() } )

        self.pingLabel:SetText( ping .. 'ms' )
        self.pingLabel:SetColor( HSVToColor( 120 - math_Clamp( ping - 10, 0, 120 ) , 1, 1 ) )
        self.pingLabel:SizeToContentsX( 2 )

        self.avatar.base:SetPlayer( ply, 32 )

        self.mic:SetMaterial( ply:IsMuted() and micMutedIcon or micIcon )
        self.mic.ply = ply 

    end

    function PANEL:OnMousePressed()
        
        self.menu = DermaMenu()
        local menu = self.menu

        menu.parent = self

        menu:AddOption( 'Открыть профиль', function()
            self.mic.ply:ShowProfile()
        end ):SetIcon( 'icon16/user_go.png' )

        menu:AddSpacer()

        local child, parent = menu:AddSubMenu( 'Телепортация' )
        parent:SetIcon'icon16/cut.png'
        child:AddOption( 'К игроку', function()

            RunConsoleCommand( 'ulx', 'goto', self.mic.ply:Nick() )

        end ):SetIcon'icon16/arrow_right.png'
        child:AddOption( 'Игрока к себе', function()
            RunConsoleCommand( 'ulx', 'bring', self.mic.ply:Nick() )
        end ):SetIcon'icon16/arrow_left.png'

        menu:AddSpacer()

        local child, parent = menu:AddSubMenu( 'Скопировать' )
        parent:SetIcon'icon16/cut.png'
        child:AddOption( 'SteamID', function()
            SetClipboardText( self.mic.ply:SteamID() )
        end )
        child:AddOption( 'SteamID64', function()
            SetClipboardText( self.mic.ply:SteamID64() )
        end )

        function menu:Think() 
            
            if !scoreboard:IsVisible() then self:Remove() end

        end

        menu:Open()

    end

    vgui.Register( 'space.scoreboard.playercard', PANEL, 'EditablePanel' )

end

do 

    local PANEL = {}

    function PANEL:Init()

        self:GetVBar():SetSize(0,0)

        self:Dock( FILL )
        self:DockMargin( 0, padding / 2, 0, 0 )
        
        self.card = {}

    end

    function PANEL:Think()

        for _, ply in ipairs( player_GetAll() ) do

            if !IsValid( ply ) then continue  end
            
            local plyID = !ply:IsBot() and ply:SteamID() or ply:Nick()

            if !IsValid( self.card[ plyID ] ) then 
                
                self.card[ plyID ] = vgui.Create( 'space.scoreboard.playercard', self )
                self.card[ plyID ].ply = ply
                local card = self.card[ plyID ]

                self:AddItem( card )
                card:DockMargin(0, 0, 0, innerPadding)

            end

            self.card[ plyID ]:SetData( ply )

        end

    end

    function PANEL:Paint( w,h )

    end

    vgui.Register( 'space.scoreboard.playerlist', PANEL, 'DScrollPanel' )

end

do 

    local PANEL = {}

    local iPadding = padding*12

    function PANEL:Init()

        self:MakePopup()
		self:SetMouseInputEnabled(false)
		self:SetKeyBoardInputEnabled(false)

        self:SetSize( ScrW() - iPadding , ScrH() - iPadding )
        self:DockPadding( padding, padding, padding, padding )
        self:Center()
		self:Hide()

        vgui.Create( 'space.scoreboard.header', self )
        vgui.Create( 'space.scoreboard.playerlist', self )

    end

    function PANEL:PerformLayout()
        
        self:SetSize( ScrW() - iPadding , ScrH() - iPadding )
        self:DockPadding( padding, padding, padding, padding )

    end

    function PANEL:Paint( w, h )
        
        draw_RoundedBox( padding, 0, 0, w, h, grey )

    end


    vgui.Register( "space.scoreboard.body", PANEL, "EditablePanel" )

end

local function Init()

    surface.CreateFont( 'space.scoreboard.font.title', { 

        font = 'Roboto',
        extended = true,
        size = ScreenScale( 15 ),
        weight = 800,
        antialias = true

     } )

    surface.CreateFont( 'space.scoreboard.font', { 

        font = 'Roboto',
        extended = true,
        size = ScreenScale( 7 ),
        weight = 500,
        antialias = true

     } )
    
    if scoreboard and ispanel( scoreboard ) then scoreboard:Remove() end

    scoreboard = vgui.Create( 'space.scoreboard.body' )

end

hook.Add( 'InitPostEntity', '_scoreboard_init', Init )

hook.Add( 'ScoreboardShow', '_scoreboard_show', function()
    
    scoreboard:Show()

    hook.Add( 'CreateMove', '_space_mouse_listener', function ( cmd )

        cmd:RemoveKey( MOUSE_LEFT )
        
        if input.WasMousePressed( MOUSE_LEFT ) or input.WasMousePressed( MOUSE_RIGHT ) then

            scoreboard:SetMouseInputEnabled( true ) 

            hook.Remove( 'Think', '_space_mouse_listener' )
        end

    end )

    return true

end)

hook.Add( 'ScoreboardHide', '_scoreboard_hide', function()

    hook.Remove( 'CreateMove', '_space_mouse_listener' )
    
    scoreboard:SetMouseInputEnabled( false )
    scoreboard:Hide()

    return true

end )

-- Init() -- debug