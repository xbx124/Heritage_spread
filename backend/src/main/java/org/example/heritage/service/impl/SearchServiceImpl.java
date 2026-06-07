package org.example.heritage.service.impl;

import org.example.heritage.common.exception.BusinessException;
import org.example.heritage.mapper.SearchMapper;
import org.example.heritage.pojo.vo.SearchVO;
import org.example.heritage.service.SearchService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class SearchServiceImpl implements SearchService {

    @Autowired
    private SearchMapper searchMapper;

    @Override
    public List<SearchVO> search(String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) {
            throw new BusinessException(400, "搜索关键词不能为空");
        }

        String trimmedKeyword = keyword.trim();
        if (trimmedKeyword.length() > 50) {
            throw new BusinessException(400, "搜索关键词不能超过50个字符");
        }

        return searchMapper.searchAll(trimmedKeyword);
    }
}