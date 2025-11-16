package com.vini.mobilidade.api.controller;

import com.vini.mobilidade.api.entity.Empresa;
import com.vini.mobilidade.api.entity.Linha;
import com.vini.mobilidade.api.repository.EmpresaRepository;
import com.vini.mobilidade.api.repository.LinhaRepository;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api")
public class MobilidadeController {

    private final LinhaRepository linhaRepository;
    private final EmpresaRepository empresaRepository;

    public MobilidadeController(LinhaRepository linhaRepository,
                                EmpresaRepository empresaRepository) {
        this.linhaRepository = linhaRepository;
        this.empresaRepository = empresaRepository;
    }

    // GET /empresas
    @GetMapping("/empresas")
    public List<Empresa> listarEmpresas() {
        return empresaRepository.findAll();
    }

    // GET /linhas/top
    // Versão simplificada: devolve todas as linhas por enquanto
    @GetMapping("/linhas/top")
    public List<Linha> listarTopLinhas() {
        return linhaRepository.findAll();
    }

    // GET /viagens/dia?data=AAAA-MM-DD
    // Por enquanto, só ecoa a data para você ver o fluxo
    @GetMapping("/viagens/dia")
    public Map<String, Object> viagensPorDia(@RequestParam("data") String data) {
        LocalDate dia = LocalDate.parse(data);
        return Map.of(
            "data", dia,
            "totalViagens", 0
        );
    }

    // GET /indicadores/geral
    @GetMapping("/indicadores/geral")
    public Map<String, Object> indicadoresGerais() {
        long totalLinhas = linhaRepository.count();
        long totalEmpresas = empresaRepository.count();

        return Map.of(
            "totalLinhas", totalLinhas,
            "totalEmpresas", totalEmpresas,
            "totalViagens", 0
        );
    }
}
