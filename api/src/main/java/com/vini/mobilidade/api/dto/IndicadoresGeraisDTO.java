package com.vini.mobilidade.api.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.LocalDate;

@Getter
@AllArgsConstructor
public class IndicadoresGeraisDTO {

    private Long totalViagens;
    private Long totalLinhasAtivas;
    private Long totalEmpresas;
    private LocalDate primeiraData;
    private LocalDate ultimaData;
}
