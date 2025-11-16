package com.vini.mobilidade.api.repository;

import com.vini.mobilidade.api.entity.Linha;
import com.vini.mobilidade.api.dto.TopLinhaDTO;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface LinhaRepository extends JpaRepository<Linha, Long> {

    @Query(value = """
            SELECT new com.vini.mobilidade.api.dto.TopLinhaDTO(
                l.codigo,
                l.nome,
                SUM(f.qtdeViagens)
            )
            FROM FatoViagem f
            JOIN Linha l ON f.linhaId = l.id
            GROUP BY l.codigo, l.nome
            ORDER BY SUM(f.qtdeViagens) DESC
            """)
    List<TopLinhaDTO> findTopLinhas();
}
