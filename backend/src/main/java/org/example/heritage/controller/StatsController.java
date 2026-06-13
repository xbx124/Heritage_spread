package org.example.heritage.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.example.heritage.common.result.PageResult;
import org.example.heritage.common.result.Result;
import org.example.heritage.pojo.dto.SpreadDataUpdateDTO;
import org.example.heritage.pojo.vo.ChannelStatsVO;
import org.example.heritage.pojo.vo.ProjectStatsVO;
import org.example.heritage.pojo.vo.SpreadDataVO;
import org.example.heritage.pojo.vo.TrendDataVO;
import org.example.heritage.service.StatsService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "传播数据统计模块")
@Slf4j
@RestController
@RequestMapping("/api/stats")
@RequiredArgsConstructor
public class StatsController {

    private final StatsService statsService;

    @Operation(summary = "渠道传播数据统计")
    @GetMapping("/channel")
    public Result<List<ChannelStatsVO>> channelStats() {
        log.info("渠道传播数据统计开始");
        List<ChannelStatsVO> list = statsService.channelStats();
        log.info("渠道传播数据统计成功，size={}", list == null ? 0 : list.size());
        return Result.success(list);
    }

    @Operation(summary = "分页查询原始传播数据记录")
    @GetMapping("/project")
    public Result<PageResult<SpreadDataVO>> projectStatsList(@RequestParam(required = false) Integer page,
                                                             @RequestParam(required = false) Integer size) {
        page = normalizePage(page);
        size = normalizeSize(size);
        log.info("分页查询原始传播数据记录开始，page={}, size={}", page, size);
        List<SpreadDataVO> list = statsService.projectStatsList(page, size);
        Long total = statsService.countProjectStatsList();
        log.info("分页查询原始传播数据记录成功，total={}, currentSize={}", total, list == null ? 0 : list.size());
        return Result.success(new PageResult<>(list, total, page, size));
    }

    @Operation(summary = "单个项目传播热度统计")
    @GetMapping("/project/{projectId}")
    public Result<ProjectStatsVO> projectStats(@PathVariable Integer projectId) {
        log.info("单个项目传播热度统计开始，projectId={}", projectId);
        ProjectStatsVO vo = statsService.projectStats(projectId);
        log.info("单个项目传播热度统计成功，projectId={}", projectId);
        return Result.success(vo);
    }

    @Operation(summary = "项目趋势数据")
    @GetMapping("/project/{projectId}/trend")
    public Result<List<TrendDataVO>> trend(@PathVariable Integer projectId) {
        log.info("项目趋势数据查询开始，projectId={}", projectId);
        List<TrendDataVO> list = statsService.trend(projectId);
        log.info("项目趋势数据查询成功，projectId={}, size={}", projectId, list == null ? 0 : list.size());
        return Result.success(list);
    }

    @Operation(summary = "手动录入传播数据")
    @PostMapping("/record")
    public Result<Void> record(@Valid @RequestBody SpreadDataUpdateDTO dto) {
        log.info("手动录入传播数据开始，projectId={}, channelId={}, statTime={}",
                dto.getProjectId(), dto.getChannelId(), dto.getStatTime());
        statsService.record(dto);
        log.info("手动录入传播数据成功，projectId={}, channelId={}, statTime={}",
                dto.getProjectId(), dto.getChannelId(), dto.getStatTime());
        return Result.success();
    }

    private Integer normalizePage(Integer page) {
        return page == null || page < 1 ? 1 : page;
    }

    private Integer normalizeSize(Integer size) {
        if (size == null || size < 1) {
            return 10;
        }
        return Math.min(size, 100);
    }
}
