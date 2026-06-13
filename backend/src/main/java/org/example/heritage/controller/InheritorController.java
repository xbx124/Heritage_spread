package org.example.heritage.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.example.heritage.common.result.PageResult;
import org.example.heritage.common.result.Result;
import org.example.heritage.pojo.dto.InheritorAddDTO;
import org.example.heritage.pojo.dto.InheritorQueryDTO;
import org.example.heritage.pojo.vo.InheritorVO;
import org.example.heritage.service.InheritorService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "非遗传承人模块")
@Slf4j
@RestController
@RequestMapping("/api/inheritors")
@RequiredArgsConstructor
public class InheritorController {

    private final InheritorService inheritorService;

    @Operation(summary = "分页查询传承人")
    @GetMapping
    public Result<PageResult<InheritorVO>> page(InheritorQueryDTO query) {
        normalizePage(query);
        log.info("分页查询传承人开始，projectId={}, page={}, size={}", query.getProjectId(), query.getPage(), query.getSize());
        List<InheritorVO> list = inheritorService.list(query);
        Long total = inheritorService.count(query);
        log.info("分页查询传承人成功，total={}, currentSize={}", total, list == null ? 0 : list.size());
        return Result.success(new PageResult<>(list, total, query.getPage(), query.getSize()));
    }

    @Operation(summary = "查询传承人详情")
    @GetMapping("/{inheritorId}")
    public Result<InheritorVO> detail(@PathVariable Integer inheritorId) {
        log.info("查询传承人详情开始，inheritorId={}", inheritorId);
        InheritorVO vo = inheritorService.detail(inheritorId);
        log.info("查询传承人详情成功，inheritorId={}", inheritorId);
        return Result.success(vo);
    }

    @Operation(summary = "新增传承人")
    @PostMapping
    public Result<Integer> add(@Valid @RequestBody InheritorAddDTO dto) {
        log.info("新增传承人开始，name={}, projectId={}", dto.getName(), dto.getProjectId());
        Integer inheritorId = inheritorService.add(dto);
        log.info("新增传承人成功，inheritorId={}", inheritorId);
        return Result.success(inheritorId);
    }

    @Operation(summary = "修改传承人")
    @PutMapping("/{inheritorId}")
    public Result<Void> update(@PathVariable Integer inheritorId,
                               @Valid @RequestBody InheritorAddDTO dto) {
        log.info("修改传承人开始，inheritorId={}, name={}, projectId={}", inheritorId, dto.getName(), dto.getProjectId());
        inheritorService.update(inheritorId, dto);
        log.info("修改传承人成功，inheritorId={}", inheritorId);
        return Result.success();
    }

    @Operation(summary = "删除传承人")
    @DeleteMapping("/{inheritorId}")
    public Result<Void> delete(@PathVariable Integer inheritorId) {
        log.info("删除传承人开始，inheritorId={}", inheritorId);
        inheritorService.delete(inheritorId);
        log.info("删除传承人成功，inheritorId={}", inheritorId);
        return Result.success();
    }

    private void normalizePage(InheritorQueryDTO query) {
        if (query.getPage() == null || query.getPage() < 1) {
            query.setPage(1);
        }
        if (query.getSize() == null || query.getSize() < 1) {
            query.setSize(10);
        }
        if (query.getSize() > 50) {
            query.setSize(50);
        }
    }
}
