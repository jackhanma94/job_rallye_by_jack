INSERT INTO `addon_account` (name, label, shared) VALUES 
	('society_rally','rally',1)
;

INSERT INTO `addon_inventory` (name, label, shared) VALUES 
	('society_rally', 'rally', 1)
;

INSERT INTO `datastore` (name, label, shared) VALUES 
	('society_rally','rally',1)
;

INSERT INTO `jobs` (`name`, `label`, `whitelisted`) VALUES
	('rally', 'rally', 1)
;

INSERT INTO `job_grades` (`job_name`, `grade`, `name`, `label`, `salary`, `skin_male`, `skin_female`) VALUES
	('rally', 0, 'pilote', 'Pilote', 30, '', ''),
	('rally', 1, 'mecano', 'Mecano', 50, '', ''),
	('rally', 2, 'copatron', 'responsable', 80, '', ''),
	('rally', 3, 'boss', 'Patron', 100, '', '')

INSERT INTO `licenses` (`type`, `label`) VALUES
	('fia', 'license de pilote')
;