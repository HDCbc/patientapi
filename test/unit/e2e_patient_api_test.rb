require File.expand_path("../../test_helper", __FILE__)
if RUBY_PLATFORM=='java'
  require 'rhino'
else
  require 'v8'
end

class E2EPatientApiTest  < Test::Unit::TestCase
  def setup
    patient_api = QueryExecutor.patient_api_javascript.to_s
    fixture_json = File.read('test/fixtures/patient/john_cleese.json')
    initialize_e2e_patient = 'var e2e_patient = new hQuery.Patient(john);'
    date = Time.new(2010,1,1)
    initialize_date = "var sampleDate = new Date(#{date.to_i*1000});"
    if RUBY_PLATFORM=='java'
      @context = Rhino::Context.new
    else
      @context = V8::Context.new
    end

    @context.eval(patient_api + "\nvar john = " + fixture_json + ";\n" + initialize_e2e_patient + "\n" + initialize_date)
  end
  
  def test_utils
    @context.eval('var encounter = e2e_patient.encounters()[0]')
    #assert_equal 2005, @context.eval('encounter.startDate().getFullYear()')
    assert_equal 2013, @context.eval('encounter.startDate().getFullYear()')
    @context.eval('encounter.setTimestamp(new Date(2010,1,1))')
    assert_equal 2010, @context.eval('encounter.startDate().getFullYear()')
  end    

  def test_demographics
    #E2E patients have been anonymomized so we expect sha224 hash strings here
    assert_equal 's/Q1SdAMY/S6mlao6erGW8sO1N0Z5XYXsSd2Ug==', @context.eval('e2e_patient.given()')
    assert_equal '7ETUHfZcSQduD+JS3qauh9vPmWUp1xbe56I3Bw==', @context.eval('e2e_patient.last()')
    assert_equal 's/Q1SdAMY/S6mlao6erGW8sO1N0Z5XYXsSd2Ug== 7ETUHfZcSQduD+JS3qauh9vPmWUp1xbe56I3Bw==', @context.eval('e2e_patient.name()')
    assert_equal 1940, @context.eval('e2e_patient.birthtime().getFullYear()')
    assert_equal 'M', @context.eval('e2e_patient.gender()')
    assert_equal 71, @context.eval('e2e_patient.age(new Date(2012,1,10))').to_i
    assert_equal 0, @context.eval('e2e_patient.addresses().length').to_i
    assert_equal nil, @context.eval('e2e_patient.addresses()[0]')
    assert_equal nil, @context.eval('e2e_patient.maritalStatus()')
    assert_equal nil, @context.eval('e2e_patient.religiousAffiliation()')
    assert_equal nil, @context.eval('e2e_patient.race()')
    assert_equal nil, @context.eval('e2e_patient.ethnicity()')
    #assert_equal 'city', @context.eval('e2e_patient.birthPlace().city()')
    assert_equal nil, @context.eval('e2e_patient.confidentiality()')
    #assert_equal 'hospital', @context.eval('e2e_patient.custodian().organizationName()')
    #assert_equal 2005, @context.eval('e2e_patient.supports().supportDate().hi().getFullYear()')
    #assert_equal 2005, @context.eval('e2e_patient.provider().careProvisionDateRange().hi().getFullYear()')
    #TODO Support patient.provider() for E2E documents.  Mismatch in provider class between HDS and patientapi
    #TODO Note that the barry_berry.json document appears to have been generated prior to change in HDS circa 2012-03-09
    #assert_equal 'Mary', @context.eval('e2e_patient.provider().providerEntity().given()')
    #assert_equal 'Care', @context.eval('e2e_patient.provider().providerEntity().last()')
    #assert_equal 'en', @context.eval('e2e_patient.languages()[0].type()[0].code()')
    assert_equal nil, @context.eval('e2e_patient.expired()')
    assert_equal nil, @context.eval('e2e_patient.clinicalTrialParticipant()')
  end

  def test_encounters
    assert_equal 6, @context.eval('e2e_patient.encounters().length')
    assert_equal 'REASON', @context.eval('e2e_patient.encounters()[0].type()[0].code()')
    #TODO Determine why "ObservationType-CA-Pending" is not returned
    assert_equal 'code',    @context.eval('e2e_patient.encounters()[0].type()[0].codeSystemName()')
    #TODO Come up with better way to retrieve patient hash
    assert_equal '1', @context.eval('e2e_patient["json"]["_id"]')
    assert_equal true, @context.eval('e2e_patient.encounters()[0].freeTextType().indexOf("130/85 sitting position") > -1')
    assert_equal nil, @context.eval('e2e_patient.encounters()[0].dischargeDisposition()')
    assert_equal nil, @context.eval('e2e_patient.encounters()[0].admitType()') #'.code()')
    assert_equal '', @context.eval('e2e_patient.encounters()[0].performer()["json"]["given_name"]')
    assert_equal 'qbGJGxVjhsCx/JR42Bd7tX4nbBYNgR/TehN7gQ==', @context.eval('e2e_patient.encounters()[0].performer()["json"]["family_name"]')
    assert_equal '', @context.eval('e2e_patient.encounters()[0].performer()["json"]["npi"]')
    #assert_equal 'doctor', @context.eval('e2e_patient.encounters()[0].performer()["json"]["given_name"]')
    #assert_equal 'oscardoc', @context.eval('e2e_patient.encounters()[0].performer()["json"]["family_name"]')
    #assert_equal 'cpsid', @context.eval('e2e_patient.encounters()[0].performer()["json"]["npi"]')
    assert_equal Time.gm(2013,9,25,15,50,0).to_i, @context.eval('e2e_patient.encounters()[0].performer()["json"]["start"]')
    assert_equal nil, @context.eval('e2e_patient.encounters()[0].performer().organization().organizationName()')
    assert_equal Time.gm(2013,9,25,15,50,0), @context.eval('e2e_patient.encounters()[0].startDate()')
    assert_equal nil, @context.eval('e2e_patient.encounters()[0].endDate()')
    assert_equal 2013, @context.eval('e2e_patient.encounters()[0].startDate().getFullYear()')
    assert_equal 8, @context.eval('e2e_patient.encounters()[0].startDate().getMonth()')
    assert_equal 25, @context.eval('e2e_patient.encounters()[0].startDate().getDate()')
    assert_equal 'Situational Crisis', @context.eval('e2e_patient.encounters()[1].reasonForVisit().freeTextType()')
    assert_equal 'ObservationType-CA-Pending', @context.eval('e2e_patient.encounters()[0].reasonForVisit().type()[0].codeSystemName()')
    assert_equal nil, @context.eval('e2e_patient.encounters()[0].facility()') #'.codeSystemName()')
    #assert_equal nil, @context.eval('e2e_patient.encounters()[0].facility().code()')
    #assert_equal nil, @context.eval('e2e_patient.encounters()[0].facility().name()')
    #TODO Change importer so lengthOfStay isn't always 0
    assert_equal 0, @context.eval('e2e_patient.encounters()[0].lengthOfStay()')
    assert_equal nil, @context.eval('e2e_patient.encounters()[0].transferTo()')
    #assert_equal "444933003", @context.eval('e2e_patient.encounters()[0].transferTo().code()')
  end

  # Not currently implemented in E2E importer
  #def test_procedures
  #  assert_equal 1, @context.eval('e2e_patient.procedures().length')
  #  assert_equal '44388', @context.eval('e2e_patient.procedures()[0].type()[0].code()')
  #  assert_equal 'CPT', @context.eval('e2e_patient.procedures()[0].type()[0].codeSystemName()')
  #  assert_equal 'Colonscopy', @context.eval('e2e_patient.procedures()[0].freeTextType()')
  #  assert @context.eval('e2e_patient.procedures()[0].includesCodeFrom({"CPT": ["44388"]})')
  #  assert_equal 1, @context.eval('e2e_patient.procedures().match({"CPT": ["44388"]}).length')
  #  assert_equal 1, @context.eval('e2e_patient.procedures().regex_match({"CPT": ["4438.*"]}).length')
  #  assert_equal 0, @context.eval('e2e_patient.procedures().match({"CPT": ["44388"]}, sampleDate).length')
  #  assert_equal 'SNOMED-CT', @context.eval('e2e_patient.procedures()[0].site().codeSystemName()')
  #  assert_equal '71854001', @context.eval('e2e_patient.procedures()[0].site().code()')
  #  assert_equal 'Bobby', @context.eval('e2e_patient.procedures()[0].performer().person().given()')
  #  assert_equal 'Tables', @context.eval('e2e_patient.procedures()[0].performer().person().last()')
  #  assert_equal '158967008', @context.eval('e2e_patient.procedures()[0].source().code()')
  #  assert_equal 1073238725000, @context.eval('e2e_patient.procedures()[0].incisionTime().getTime()')
  #end

  def test_vital_signs
    assert_equal 7, @context.eval('e2e_patient.vitalSigns().length')
    assert_equal '8480-6', @context.eval('e2e_patient.vitalSigns()[0].type()[0].code()')
    assert_equal 'LOINC', @context.eval('e2e_patient.vitalSigns()[0].type()[0].codeSystemName()')
    #TODO Implment capture of status and statusCode information in HDS E2E importer
    assert_equal nil, @context.eval('e2e_patient.vitalSigns()[0].status()')
    #assert_equal 'completed', @context.eval('e2e_patient.vitalSigns()[0].status()')
    assert_equal nil, @context.eval('e2e_patient.vitalSigns()[0].statusCode()')
    #assert_equal 'completed', @context.eval('e2e_patient.vitalSigns()[0].statusCode()["HL7 ActStatus"][0]')
    assert_equal 85, @context.eval('e2e_patient.vitalSigns()[1].values()[0].scalar()')
    assert_equal 'mm[Hg]', @context.eval('e2e_patient.vitalSigns()[1].values()[0].units()')
    assert_equal '8462-4', @context.eval('e2e_patient.vitalSigns()[1].resultType()[0].code()')
    #TODO implement capture of comment in HDS E2E importer
    assert_equal nil, @context.eval('e2e_patient.vitalSigns()[1].comment()')
    #assert_equal 'BP taken sitting', @context.eval('e2e_patient.vitalSigns()[1].comment()')
  end
  
  def test_results
    assert_equal 28, @context.eval('e2e_patient.results().length')
    assert_equal '6690-2', @context.eval('e2e_patient.results()[0].type()[0].code()')
    assert_equal 'pCLOCD', @context.eval('e2e_patient.results()[0].type()[0].codeSystemName()')
    assert_equal 'pCLOCD', @context.eval('e2e_patient.results()[0].resultType()[0].codeSystemName()')
    #TODO Capture status in HDS E2E importer
    assert_equal nil, @context.eval('e2e_patient.results()[0].status()')
    #TODO Capture comment in HDS E2E importer
    assert_equal nil, @context.eval('e2e_patient.results()[0].comment()')
  end

  def test_conditions
    assert_equal 4, @context.eval('e2e_patient.conditions().length')
    assert @context.eval('e2e_patient.conditions().match({"ICD9": ["401"]}).length != 0')
    assert @context.eval('e2e_patient.conditions().match({"ICD9": ["428"]}).length != 0')
    assert_equal nil, @context.eval('e2e_patient.conditions()[1].ageAtOnset()')
    assert_equal nil, @context.eval('e2e_patient.conditions()[1].problemStatus()')
    assert_equal nil, @context.eval('e2e_patient.conditions()[1].severity()')
    assert_equal nil, @context.eval('e2e_patient.conditions()[1].diagnosisPriority()')
    assert_equal nil, @context.eval('e2e_patient.conditions()[1].ordinality()')
  end

  def test_medications
    assert_equal 9, @context.eval('e2e_patient.medications().length')
    #TODO Implement frequency in addition to period which isn't used in Oscar McMaster EMR.
    assert_equal nil, @context.eval('e2e_patient.medications()[0].administrationTiming().period()') #'.value()')
    assert_equal nil, @context.eval('e2e_patient.medications()[0].administrationTiming().institutionSpecified()')
    #assert_equal 'tablet', @context.eval('e2e_patient.medications()[0].dose().unit()')
    assert_equal 'TYLENOL EXTRA STRENGTH TAB 500MG', @context.eval('e2e_patient.medications()[0].medicationInformation().freeTextProductName()')
    assert_equal 1, @context.eval('e2e_patient.medications().match({"HC-DIN": ["00559407"]}).length')
    assert_equal 'PO', @context.eval('e2e_patient.medications()[0].route().code()')
    assert_equal ' E2E_PRN_FLAG E2E_LONG_TERM_FLAG', @context.eval('e2e_patient.medications()[0].freeTextSig()')
    assert_equal true, @context.eval('e2e_patient.medications()[0].isPRN()')
    assert_equal true, @context.eval('e2e_patient.medications()[0].isLongTerm()')
    # HDS E2E importer doesn't support fulfillmentHistory
    #assert_equal 30, @context.eval('e2e_patient.medications()[0].fulfillmentHistory()[0].quantityDispensed().value()')
    # FIXME typeOfMedication and statusOfMedication don't really work
    assert_equal false, @context.eval('e2e_patient.medications()[0].typeOfMedication().isOverTheCounter()')
    assert_equal false, @context.eval('e2e_patient.medications()[0].statusOfMedication().isActive()')
    # E2E HDS importer doesn't support orderInformation(), cumulativeMedicationDuration() nor reason()
    #assert_equal 30, @context.eval('e2e_patient.medications()[0].orderInformation()[0].quantityOrdered().value()')
    #assert_equal 20, @context.eval('e2e_patient.medications()[0].orderInformation()[0].fills()')
    #assert_equal 3, @context.eval('e2e_patient.medications()[0].cumulativeMedicationDuration()["scalar"]')
    assert_equal nil, @context.eval('e2e_patient.medications()[0].reason()')
    #assert_equal "195911009", @context.eval('e2e_patient.medications()[0].reason().code()')
  end
  
  def test_immunizations
    assert_equal 3, @context.eval('e2e_patient.immunizations().length')
    assert_equal 3, @context.eval('e2e_patient.immunizations().withoutNegation().length')
    assert_equal 0, @context.eval('e2e_patient.immunizations().withNegation().length')
    #assert_equal 1, @context.eval('e2e_patient.immunizations().withNegation({"HL7 No Immunization Reason":["IMMUNE"]}).length')
    #assert_equal 0, @context.eval('e2e_patient.immunizations().withNegation({"HL7 No Immunization Reason":["OSTOCK"]}).length')
    assert_equal 1, @context.eval('e2e_patient.immunizations().match({"whoATC": ["J07BB01"]}).length')
    assert_equal 1, @context.eval('e2e_patient.immunizations().match({"whoATC": ["J07AL02"]}).length')
    assert_equal 1, @context.eval('e2e_patient.immunizations().match({"whoATC": ["J07CA01"]},null,null,true).length')
    assert_equal 'Td', @context.eval('e2e_patient.immunizations()[0].medicationInformation().freeTextProductName()')
    assert_equal nil, @context.eval('e2e_patient.immunizations()[0].medicationSeriesNumber()') #'.value()')
    assert_equal nil, @context.eval('e2e_patient.immunizations()[0].comment()')
    assert_equal nil, @context.eval('e2e_patient.immunizations()[1].refusalInd()')
    assert_equal false, @context.eval('e2e_patient.immunizations()[1].refusalReason().isImmune()')
    assert_equal false, @context.eval('e2e_patient.immunizations()[1].negationInd()')
    assert_equal nil, @context.eval('e2e_patient.immunizations()[1].negationReason()')
    #assert_equal 'IMMUNE', @context.eval('e2e_patient.immunizations()[1].negationReason().code()')
    assert_equal nil, @context.eval('e2e_patient.immunizations()[1].performer()')
    #TODO Implement performer for immunization section of HDS importer - easiest approach would be to revert to performer hash field
    #assert_equal 'FirstName', @context.eval('e2e_patient.immunizations()[1].performer().person().given()')
    #assert_equal 'LastName', @context.eval('e2e_patient.immunizations()[1].performer().person().last()')
    #assert_equal 1, @context.eval('e2e_patient.immunizations()[1].performer().person().addresses().length')
    #assert_equal '100 Bureau Drive', @context.eval('e2e_patient.immunizations()[1].performer().person().addresses()[0].street()[0]')
    #assert_equal 'Gaithersburg', @context.eval('e2e_patient.immunizations()[1].performer().person().addresses()[0].city()')
    #assert_equal 'MD', @context.eval('e2e_patient.immunizations()[1].performer().person().addresses()[0].state()')
    #assert_equal '20899', @context.eval('e2e_patient.immunizations()[1].performer().person().addresses()[0].postalCode()')
  end
  
  def test_allergies
    assert_equal 1, @context.eval('e2e_patient.allergies().length')
    assert_equal nil,@context.eval('e2e_patient.allergies()[0].comment()')
    assert_equal 1, @context.eval('e2e_patient.allergies().match({"Unknown": ["NI"]}).length')
    assert_equal 'PENICILLINS, COMBINATIONS WITH OTHER ANTIBACTERIAL', @context.eval('e2e_patient.allergies()[0].freeTextType()')
    assert_equal nil, @context.eval('e2e_patient.allergies()[0].reaction().code()')
    assert_equal nil, @context.eval('e2e_patient.allergies()[0].severity()')
    assert_equal Time.gm(2013,3,5).to_i*1000.0, @context.eval('e2e_patient.allergies()[0].startDate().getTime()')
    assert_equal Time.gm(2013,3,5).to_i*1000.0, @context.eval('e2e_patient.allergies()[0].timeStamp().getTime()')
    assert_equal Time.gm(2013,3,5), @context.eval('e2e_patient.allergies()[0].startDate()')
    assert_equal nil, @context.eval('e2e_patient.allergies()[0].endDate()')
    assert_equal false, @context.eval('e2e_patient.allergies()[0].isTimeRange()')
  end

  # Not currently implemented in E2E importer
  #def test_pregnancies
  #  assert_equal 1, @context.eval('e2e_patient.pregnancies().length')
  #  assert_equal 1, @context.eval('e2e_patient.pregnancies().match({"SNOMED-CT": ["77386006"]}).length')
  #end

  # Not currently implemented in E2E importer
  #def test_socialhistory
  #  assert_equal 1, @context.eval('e2e_patient.socialHistories().length')
  #  assert_equal 1, @context.eval('e2e_patient.socialHistories().match({"SNOMED-CT": ["229819007"]}).length')
  #end

  # Not currently implemented in E2E importer
  #def test_functional_status
  #  assert_equal 1, @context.eval('e2e_patient.functionalStatuses().length')
  #  assert_equal 'result', @context.eval('e2e_patient.functionalStatuses()[0].type()')
  #  assert_equal 'e2e_patient reported', @context.eval('e2e_patient.functionalStatuses()[0].source().code()')
  #end

  # Not currently implemented in E2E importer
  #def test_medical_equipment
  #  assert_equal 1, @context.eval('e2e_patient.medicalEquipment().length')
  #  assert_equal '13648007', @context.eval('e2e_patient.medicalEquipment()[0].anatomicalStructure().code()')
  #end
  
end