USE [PS_GameData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Create_Char_R]    Script Date: 6/6/2015 12:41:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

ALTER  Proc [dbo].[usp_Create_Char_R]

	@serverID tinyint, @userID varchar(12), @userUID int, @charName varchar(50),
	@slot Tinyint, @family Tinyint, @grow Tinyint,
	@hair Tinyint, @face Tinyint, @size Tinyint, @job Tinyint, @sex Tinyint,
	@level Smallint, @statpoint Smallint, @skillpoint Smallint,
	@str Smallint, @dex Smallint, @rec Smallint, @int Smallint,
	@luc Smallint, @wis Smallint, @HP Smallint, @MP Smallint, @SP Smallint,
	@map Smallint, @dir Smallint, @exp Int, @money Int,
	@posX Real, @posY Real, @posZ Real,
	@Hg Smallint, @Vg Smallint, @Cg Tinyint, @Og Tinyint, @Ig Tinyint

AS

SET NOCOUNT ON

declare @result int

SET @charName = LTRIM(RTRIM(@charName))
SET @SkillPoint = 5  /*** 5 **/
set @result = 0


if exists (select CharID from Chars where CharName=@charName and
	(Del=0 or (Del=1 and Level>10 and DeleteDate>DATEADD(dd, -7, GETDATE()))))
begin
	set @result = -2
end
else
begin

-- Changes starts Here

	if exists (select level from PS_GameDefs.dbo.CharDefs where
		grow=@grow and family=@family and job=@job)
	begin
	--	replace some received values with data read from our table
		/*select @level=[level], @statPoint=[statPoint], @skillPoint=[skillPoint],
			@str=[str], @dex=[dex], @rec=[rec], @int=[int], @luc=[luc], @wis=[wis],
			@HP=[HP], @MP=[MP], @SP=[SP], @exp=[exp], @money=[money],
			@map=[map], @dir=[dir], @posX=[posX], @posY=[posY], @posz=[posZ]
		from PS_GameDefs.dbo.CharDefs
		where grow=@grow and family=@family and job=@job
		
		--	set mode to ultimate (valid for "immediate leveling" use only)
		set @grow = 3
		

		grow: easy(0), normal(1), hard(2), ultimate(3)
		*/

		select @level=[level], @statPoint=[statPoint], @skillPoint=[skillPoint],
			@str=[str], @dex=[dex], @rec=[rec], @int=[int], @luc=[luc], @wis=[wis],
			@HP=[HP], @MP=[MP], @SP=[SP], @exp=[exp], @money=[money],
			@map=[map], @dir=[dir], @posX=[posX], @posY=[posY], @posz=[posZ]
		from PS_GameDefs.dbo.CharDefs
		where grow=@grow and family=@family and job=@job			
		
		
	end

-- Changes Ends Here

	begin transaction

--	create toon with updated information
	insert into Chars(ServerID, UserID, UserUID, CharName, Slot, Family, Grow, 
		Hair, Face, [Size], Job, Sex, [Level], StatPoint, SkillPoint, 
		[Str], Dex, Rec, [Int], Luc, Wis, HP, MP, SP, Map, Dir, [Exp], [Money], 
		PosX, PosY, Posz, Hg, Vg, Cg, Og, Ig, RenameCnt, RemainTime)
	values (
		@serverID, @userID, @userUID, @charName, @slot, @family, @grow, 
		@hair, @face, @size, @job, @sex, @level, @statPoint, @skillPoint, 
		@str, @dex, @rec, @int, @luc, @wis, @HP, @MP, @SP, @map, @dir,
		@exp, @money, @posX, @posY, @posz, @Hg, @Vg, @Cg, @Og, @Ig, 0, 0)

		

	/**** lấy ngay moi nhất ****/
	declare @newdate datetime;
	select @newdate = Max(RegDate)
	from Chars;
	
	update Chars
	set StatPoint = 0, SkillPoint=0, grow=3
	where (grow=1 or grow=2 or grow=3) and RegDate=@newdate

	update Chars
	set StatPoint = 420, SkillPoint=420, grow=2
	where (grow=0 and RegDate=@newdate)

/**** change stat point here ******/


	if (@@ERROR <> 0)
	begin
		rollback transaction
		set @result = -1
	end
	else
	begin
		commit transaction
		set @result = IDENT_CURRENT('Chars')
		
		INSERT INTO CharItems
SELECT @result AS CharID,ItemID,dbo.ItemUID() AS ItemUID,Type,TypeID,Bag,Slot,Quality,Gem1,Gem2,Gem3,Gem4,Gem5,Gem6,Craftname,1 AS COUNT,GETDATE() AS Maketime,'S' AS Maketype,0 AS Del
FROM PS_GameDefs.dbo.BaseGearsDefs WHERE Family = @Family AND Job = @Job AND Level = @Level



SELECT SkillID,MAX(SkillLevel) AS SkillLevel,MAX(Country) AS Country,MAX(Grow) AS Grow,MAX(Attackfighter) AS Attackfighter,MAX(Defensefighter) AS Defensefighter,MAX(Patrolrogue) AS Patrolrogue,MAX(Shootrogue) AS Shootrogue,MAX(Attackmage) AS Attackmage,MAX(Defensemage) AS Defensemage INTO #Skills
FROM PS_GameDefs.dbo.Skills
WHERE ReqLevel <= @Level AND 
	SkillLevel < 100 AND 
	TypeShow > 0 AND 
	(((@Job != 0 OR (Attackfighter = 1)) AND ((@Family != 0 OR (Country IN (6,2,0))) AND (@Family != 3 OR (Country IN (6,5,3)))))
		AND ((@Job != 1 OR (Defensefighter = 1)) AND ((@Family != 0 OR (Country IN (6,2,0))) AND (@Family != 3 OR (Country IN (6,5,3)))))
		AND ((@Job != 2 OR (Patrolrogue = 1)) AND ((@Family != 1 OR (Country IN (6,2,1))) AND (@Family != 2 OR (Country IN (6,5,4)))))
		AND ((@Job != 3 OR (Shootrogue = 1)) AND ((@Family != 1 OR (Country IN (6,2,1))) AND (@Family != 3 OR (Country IN (6,5,3)))))
		AND ((@Job != 4 OR (Attackmage = 1)) AND ((@Family != 1 OR (Country IN (6,2,1))) AND (@Family != 2 OR (Country IN (6,5,4)))))
		AND ((@Job != 5 OR (Defensemage = 1)) AND ((@Family != 0 OR (Country IN (6,2,0))) AND (@Family != 2 OR (Country IN (6,5,4))))))
GROUP BY SkillID

DECLARE @Count INT 
SET @Count = (SELECT COUNT(SkillLevel) FROM #Skills)

WHILE @Count > 0
BEGIN
	INSERT INTO CharSkills
	SELECT TOP (1) @result,SkillID,SkillLevel,@Count,0,GETDATE(),0
	FROM #Skills

	DELETE TOP (1) FROM #Skills

	SET @Count = @Count - 1
END

DROP TABLE #Skills
			
	end
end

SET NOCOUNT OFF
return @result