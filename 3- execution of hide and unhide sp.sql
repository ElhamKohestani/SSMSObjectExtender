-- Get All tables which are hidden
select * from sys.tables
where object_id in (select major_id from sys.extended_properties where [value] = 'Hide' and [name] = 'microsoft_database_tools_support')

-- Unhide specific tables
exec ekt_sp_UnHideObjectsInObjectExplorer N'dbo', N'Lib', 0;