package org.example.heritage.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.example.heritage.common.result.Result;
import org.example.heritage.pojo.dto.ChannelAddDTO;
import org.example.heritage.pojo.vo.ChannelVO;
import org.example.heritage.service.ChannelService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "传播渠道模块")
@Slf4j
@RestController
@RequestMapping("/api/channels")
@RequiredArgsConstructor
public class ChannelController {

    private final ChannelService channelService;

    @Operation(summary = "查询渠道列表")
    @GetMapping
    public Result<List<ChannelVO>> list() {
        log.info("查询渠道列表开始");
        List<ChannelVO> list = channelService.list();
        log.info("查询渠道列表成功，size={}", list == null ? 0 : list.size());
        return Result.success(list);
    }

    @Operation(summary = "新增渠道")
    @PostMapping
    public Result<Integer> add(@Valid @RequestBody ChannelAddDTO dto) {
        log.info("新增渠道开始，channelName={}, channelType={}", dto.getChannelName(), dto.getChannelType());
        Integer channelId = channelService.add(dto);
        log.info("新增渠道成功，channelId={}", channelId);
        return Result.success(channelId);
    }

    @Operation(summary = "修改渠道")
    @PutMapping("/{channelId}")
    public Result<Void> update(@PathVariable Integer channelId,
                               @Valid @RequestBody ChannelAddDTO dto,
                               @RequestParam(required = false) Integer status) {
        log.info("修改渠道开始，channelId={}, channelName={}, channelType={}, status={}",
                channelId, dto.getChannelName(), dto.getChannelType(), status);
        channelService.update(channelId, dto, status);
        log.info("修改渠道成功，channelId={}", channelId);
        return Result.success();
    }

    @Operation(summary = "删除渠道")
    @DeleteMapping("/{channelId}")
    public Result<Void> delete(@PathVariable Integer channelId) {
        log.info("删除渠道开始，channelId={}", channelId);
        channelService.delete(channelId);
        log.info("删除渠道成功，channelId={}", channelId);
        return Result.success();
    }
}
