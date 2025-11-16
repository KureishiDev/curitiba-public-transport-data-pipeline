package com.vini.mobilidade.api.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "dim_empresa", schema = "gold_mobilidade")
@Getter
@Setter
@NoArgsConstructor
public class Empresa {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "empresa_codigo")
    private String codigo;

    @Column(name = "empresa_nome")
    private String nome;
}
