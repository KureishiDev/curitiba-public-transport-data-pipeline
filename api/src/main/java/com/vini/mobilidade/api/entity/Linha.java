package com.vini.mobilidade.api.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "dim_linha", schema = "gold_mobilidade")
@Getter
@Setter
@NoArgsConstructor
public class Linha {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "cod_linha")
    private String codigo;

    @Column(name = "nome_linha")
    private String nome;

    @Column(name = "empresa_codigo")
    private String empresaCodigo;
}
