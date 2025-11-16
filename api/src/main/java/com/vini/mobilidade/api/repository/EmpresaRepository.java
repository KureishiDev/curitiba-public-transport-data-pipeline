package com.vini.mobilidade.api.repository;

import com.vini.mobilidade.api.entity.Empresa;
import org.springframework.data.jpa.repository.JpaRepository;

public interface EmpresaRepository extends JpaRepository<Empresa, Long> {
}
