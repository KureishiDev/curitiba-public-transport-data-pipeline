package com.vini.mobilidade.api.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class TopLinhaDTO {

    private String codigo;
    private String nome;
    private Long totalViagens;
}
