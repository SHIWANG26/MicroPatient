package com.pm.patientservice.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.pm.patientservice.dto.PatientRequestDTO;
import com.pm.patientservice.dto.PatientResponseDTO;
import com.pm.patientservice.mapper.PatientMapper;
import com.pm.patientservice.model.Patient;
import com.pm.patientservice.repository.PatientRepository;

@Service
public class PatientService {
    private PatientRepository patientRepository;

    public PatientService(PatientRepository patientRepository) {
        // Constructor-based dependency injection
        this.patientRepository = patientRepository;
    }

    public List<PatientResponseDTO> getPatients() {
        List<Patient> patients = patientRepository.findAll();
        // Convert List<Patient> to List<PatientResponseDTO> using lambda
        return patients.stream()
                .map(PatientMapper::toDTO)
                .toList();
    }

    public PatientResponseDTO createPatient(PatientRequestDTO patientRequestDTO){
        Patient newPatient = patientRepository.save(PatientMapper.toModel(patientRequestDTO));
        return PatientMapper.toDTO(newPatient);
    }
}
