package org.example.heritage.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.example.heritage.common.result.PageResult;
import org.example.heritage.common.result.Result;
import org.example.heritage.pojo.dto.ProjectAddDTO;
import org.example.heritage.pojo.dto.ProjectPageQueryDTO;
import org.example.heritage.pojo.vo.ProjectDetailVO;
import org.example.heritage.pojo.vo.ProjectListVO;
import org.example.heritage.service.ProjectService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "非遗项目模块")
@Slf4j
@RestController
@RequestMapping("/api/projects")
@RequiredArgsConstructor
public class ProjectController {

    private final ProjectService projectService;

    @Operation(summary = "分页查询非遗项目")
    @GetMapping
    public Result<PageResult<ProjectListVO>> page(ProjectPageQueryDTO query) {
        normalizePage(query);
        log.info("分页查询非遗项目开始，categoryId={}, keyword={}, page={}, size={}",
                query.getCategoryId(), query.getKeyword(), query.getPage(), query.getSize());
        List<ProjectListVO> list = projectService.list(query);
        Long total = projectService.count(query);
        log.info("分页查询非遗项目成功，total={}, currentSize={}", total, list == null ? 0 : list.size());
        return Result.success(new PageResult<>(list, total, query.getPage(), query.getSize()));
    }

    @Operation(summary = "查询项目详情")
    @GetMapping("/{projectId}")
    public Result<ProjectDetailVO> detail(@PathVariable Integer projectId) {
        log.info("查询项目详情开始，projectId={}", projectId);
        ProjectDetailVO detail = projectService.detail(projectId);
        log.info("查询项目详情成功，projectId={}", projectId);
        return Result.success(detail);
    }

    @Operation(summary = "新增非遗项目")
    @PostMapping
    public Result<Integer> add(@Valid @RequestBody ProjectAddDTO dto) {
        log.info("新增非遗项目开始，projectName={}, categoryId={}", dto.getProjectName(), dto.getCategoryId());
        Integer projectId = projectService.add(dto);
        log.info("新增非遗项目成功，projectId={}", projectId);
        return Result.success(projectId);
    }

    @Operation(summary = "修改非遗项目")
    @PutMapping("/{projectId}")
    public Result<Void> update(@PathVariable Integer projectId,
                               @Valid @RequestBody ProjectAddDTO dto) {
        log.info("修改非遗项目开始，projectId={}, projectName={}, categoryId={}",
                projectId, dto.getProjectName(), dto.getCategoryId());
        projectService.update(projectId, dto);
        log.info("修改非遗项目成功，projectId={}", projectId);
        return Result.success();
    }

    @Operation(summary = "删除非遗项目")
    @DeleteMapping("/{projectId}")
    public Result<Void> delete(@PathVariable Integer projectId) {
        log.info("删除非遗项目开始，projectId={}", projectId);
        projectService.delete(projectId);
        log.info("删除非遗项目成功，projectId={}", projectId);
        return Result.success();
    }

    private void normalizePage(ProjectPageQueryDTO query) {
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
