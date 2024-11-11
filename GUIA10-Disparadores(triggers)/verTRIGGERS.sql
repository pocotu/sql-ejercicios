SELECT name AS TriggerName,
       parent_class_desc AS Scope,
       type_desc AS TriggerType
FROM sys.triggers;
