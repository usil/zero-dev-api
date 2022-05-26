-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Table `web_hook`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `web_hook` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL COMMENT 'The name of the webhook',
  `endpoint` VARCHAR(45) NOT NULL COMMENT 'the endpoint to call the webhook',
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `application`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `application` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `version` VARCHAR(8) NOT NULL COMMENT 'For the application version control',
  `name` VARCHAR(75) NOT NULL COMMENT 'The name of the application',
  `port` VARCHAR(4) NOT NULL COMMENT 'The where the app will be used',
  `cpu` TINYINT NULL COMMENT 'How many cpus the app should use',
  `memory` INT NULL COMMENT 'How many memoy should the app use',
  `generalVisualConfiguration` JSON NULL COMMENT 'A set of properties to set the visual style of the application\n',
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `entity`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `entity` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `applicationId` INT UNSIGNED NOT NULL,
  `webHookId` INT UNSIGNED NULL,
  `name` VARCHAR(75) NOT NULL COMMENT 'The name of the form',
  `icon` VARCHAR(45) NULL COMMENT 'The icons that represents the form',
  `visible` TINYINT(1) NULL DEFAULT 1 COMMENT 'Is this entity visible',
  `useSteps` TINYINT(1) NULL DEFAULT 0 COMMENT 'Use the turorial steps',
  `disableReport` TINYINT(1) NULL DEFAULT 0 COMMENT 'Do not show report',
  `disableExcelExport` TINYINT(1) NULL DEFAULT 0 COMMENT 'Disable the export to excel value',
  `viewListType` VARCHAR(20) NULL DEFAULT 'table' COMMENT 'Either view the data as a table, a list or a list of cards',
  PRIMARY KEY (`id`),
  INDEX `fk_Entity_WebHook1_idx` (`webHookId` ASC) ,
  INDEX `fk_Entity_Application1_idx` (`applicationId` ASC) ,
  CONSTRAINT `fk_Entity_WebHook1`
    FOREIGN KEY (`webHookId`)
    REFERENCES `web_hook` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Entity_Application1`
    FOREIGN KEY (`applicationId`)
    REFERENCES `application` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `data_origin`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `data_origin` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `identifier` VARCHAR(65) NOT NULL COMMENT 'A identifier for the origin of the data',
  `type` VARCHAR(35) NULL COMMENT 'What type of data the origin has',
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `field`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `field` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `entityId` INT UNSIGNED NOT NULL,
  `dataOriginId` INT UNSIGNED NOT NULL,
  `name` VARCHAR(65) NOT NULL COMMENT 'The field name',
  `alias` VARCHAR(65) NOT NULL COMMENT 'An alias for the field',
  `required` TINYINT(1) NULL DEFAULT 1 COMMENT 'Is this field required ',
  `defaultValue` VARCHAR(100) NULL COMMENT 'What is this field default value',
  `visibleOnForm` TINYINT(1) NULL DEFAULT 1 COMMENT 'Is visible at the moment of creation',
  `visibleOnList` TINYINT(1) NULL DEFAULT 1 COMMENT 'Is visible on the list',
  `useAsFilter` TINYINT(1) NULL DEFAULT 0 COMMENT 'Use this field as a filter',
  PRIMARY KEY (`id`),
  INDEX `fk_Field_Form1_idx` (`entityId` ASC) ,
  INDEX `fk_Field_DataOrigin1_idx` (`dataOriginId` ASC) ,
  CONSTRAINT `fk_Field_Form1`
    FOREIGN KEY (`entityId`)
    REFERENCES `entity` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Field_DataOrigin1`
    FOREIGN KEY (`dataOriginId`)
    REFERENCES `data_origin` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `foreign_relation`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `foreign_relation` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `foreignTableName` VARCHAR(75) NOT NULL COMMENT 'Form table name\n',
  `foreignFieldToShow` VARCHAR(45) NOT NULL COMMENT 'Field to show of the foreign column',
  `intermediateTable` VARCHAR(75) NULL COMMENT 'The link table if the relationship is many to many',
  `showForeignForm` TINYINT(1) NULL DEFAULT 0 COMMENT 'Show the foreign form',
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `input_type`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `input_type` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `typeName` VARCHAR(75) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `fieldInput_visual_configuration`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `fieldInput_visual_configuration` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `inputTypeId` INT UNSIGNED NOT NULL,
  `fieldId` INT UNSIGNED NOT NULL,
  `label` VARCHAR(45) NOT NULL,
  `disabled` TINYINT(1) NULL DEFAULT 0,
  `advancedConfiguration` JSON NULL,
  `cssConfiguration` JSON NULL,
  `validatorsConfiguration` JSON NULL,
  `tooltip` VARCHAR(45) NULL,
  `stereotype` VARCHAR(45) NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_FieldInputConfiguration_InputType1_idx` (`inputTypeId` ASC) ,
  INDEX `fk_FieldInputConfiguration_Field1_idx` (`fieldId` ASC) ,
  CONSTRAINT `fk_FieldInputConfiguration_InputType1`
    FOREIGN KEY (`inputTypeId`)
    REFERENCES `input_type` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_FieldInputConfiguration_Field1`
    FOREIGN KEY (`fieldId`)
    REFERENCES `field` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `tutorial_step`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `tutorial_step` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `formId` INT UNSIGNED NOT NULL,
  `fieldId` INT UNSIGNED NULL,
  `order` SMALLINT NOT NULL COMMENT 'The order to show the turorial',
  `message` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_TutorialStep_Field1_idx` (`fieldId` ASC) ,
  INDEX `fk_TutorialStep_Form1_idx` (`formId` ASC) ,
  CONSTRAINT `fk_TutorialStep_Field1`
    FOREIGN KEY (`fieldId`)
    REFERENCES `field` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_TutorialStep_Form1`
    FOREIGN KEY (`formId`)
    REFERENCES `entity` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `composed_origin`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `composed_origin` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `DataOrigin_dataOriginId` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_ComposedOrigin_DataOrigin1_idx` (`DataOrigin_dataOriginId` ASC) ,
  CONSTRAINT `fk_ComposedOrigin_DataOrigin1`
    FOREIGN KEY (`DataOrigin_dataOriginId`)
    REFERENCES `data_origin` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `data_base_origin`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `data_base_origin` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `foreignRelationId` INT UNSIGNED NOT NULL,
  `dataOriginId` INT UNSIGNED NOT NULL,
  `tableField` VARCHAR(45) NOT NULL COMMENT 'The table where the data is at',
  `table` VARCHAR(45) NOT NULL COMMENT 'The table where the data is at',
  `variableType` VARCHAR(45) NULL COMMENT 'The database type',
  PRIMARY KEY (`id`),
  INDEX `fk_DataBaseOrigin_DataOrigin1_idx` (`dataOriginId` ASC) ,
  INDEX `fk_DataBaseOrigin_ForeignRelation1_idx` (`foreignRelationId` ASC) ,
  CONSTRAINT `fk_DataBaseOrigin_DataOrigin1`
    FOREIGN KEY (`dataOriginId`)
    REFERENCES `data_origin` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_DataBaseOrigin_ForeignRelation1`
    FOREIGN KEY (`foreignRelationId`)
    REFERENCES `foreign_relation` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `rest_origin`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `rest_origin` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `dataOriginId` INT UNSIGNED NOT NULL,
  `endpoint` VARCHAR(75) NOT NULL COMMENT 'The endpoint to get the data',
  `httpConfiguration` JSON NULL COMMENT 'The http configuration to use the endpoint',
  `jsonPath` VARCHAR(155) NULL COMMENT 'Json path to get the exact value',
  `variableType` VARCHAR(45) NULL COMMENT 'The type of the variable',
  PRIMARY KEY (`id`),
  INDEX `fk_RestOrigin_DataOrigin1_idx` (`dataOriginId` ASC) ,
  CONSTRAINT `fk_RestOrigin_DataOrigin1`
    FOREIGN KEY (`dataOriginId`)
    REFERENCES `data_origin` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `step_by_step`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `step_by_step` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL COMMENT 'The name of this step by step form',
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `step_by_step_configuration`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `step_by_step_configuration` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `formId` INT UNSIGNED NOT NULL,
  `stepByStepId` INT UNSIGNED NOT NULL,
  `order` SMALLINT NOT NULL COMMENT 'In witch order the steps goes on',
  `previusIsRequired` TINYINT(1) NULL DEFAULT 1 COMMENT 'If the previous form is required',
  PRIMARY KEY (`id`),
  INDEX `fk_StepByStepConfiguration_StepByStep1_idx` (`stepByStepId` ASC) ,
  INDEX `fk_StepByStepConfiguration_Form1_idx` (`formId` ASC) ,
  CONSTRAINT `fk_StepByStepConfiguration_StepByStep1`
    FOREIGN KEY (`stepByStepId`)
    REFERENCES `step_by_step` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_StepByStepConfiguration_Form1`
    FOREIGN KEY (`formId`)
    REFERENCES `entity` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `composed_origin_field`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `composed_origin_field` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `composedOriginId` INT UNSIGNED NOT NULL,
  `fieldId` INT UNSIGNED NOT NULL,
  `operation` VARCHAR(5) NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_ComposedOriginField_ComposedOrigin1_idx` (`composedOriginId` ASC) ,
  INDEX `fk_ComposedOriginField_Field1_idx` (`fieldId` ASC) ,
  CONSTRAINT `fk_ComposedOriginField_ComposedOrigin1`
    FOREIGN KEY (`composedOriginId`)
    REFERENCES `composed_origin` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_ComposedOriginField_Field1`
    FOREIGN KEY (`fieldId`)
    REFERENCES `field` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
