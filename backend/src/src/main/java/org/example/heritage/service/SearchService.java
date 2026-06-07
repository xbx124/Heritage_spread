package org.example.heritage.service;

import org.example.heritage.pojo.vo.SearchVO;

import java.util.List;

public interface SearchService {

    List<SearchVO> search(String keyword);
}